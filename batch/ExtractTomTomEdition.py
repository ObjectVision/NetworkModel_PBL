# Sets up a TomTom edition folder the way cfg/main/SourceData/TomTom.dms reads it:
#
#   %NetworkModel_PrivDir%/TomTom/<file_date>/multinet/*.shp       (MultiNet tiles, flat)
#   %NetworkModel_PrivDir%/TomTom/<file_date>/speedprofiles/*.dbf  (speed profiles, flat)
#   %NetworkModel_PrivDir%/TomTom/<file_date>/doc/                 (documentation, unchanged)
#
# from a TomTom delivery as a zip of .7z.001 volumes. Three peculiarities require a custom
# writer instead of a plain py7zr.extractall():
#   1. the archive names start with a '/' ('/eur2025_12_000/shpa/mn/nld/ax/...'); the normal
#      write route of py7zr 1.1 trips over that in its path check ("Specified path is
#      bad"), the factory route does not (the sanitizer strips the slash and MemIO skips the check);
#   2. each shapefile part is gzipped separately ('..._a7.shp.gz'); the reader needs .shp/.dbf;
#   3. the reader needs multinet/ and speedprofiles/ FLAT: the shape type sniff in TomTom.dms
#      (`file_str_values`, StorageType "strfiles", StorageName "=first(FolderName)") puts the folder
#      of the FIRST file before every file name, so files in subfolders are not
#      found (_fsopen fails). Subfolders per archive are not needed either: TomTom names carry
#      the tile code (belbe210000______nw.shp), so they do not collide; GunzipWriter checks this.
# Hence: extractall() with a WriterFactory that receives each member in memory, gunzips it and
# writes it under its bare file name to multinet/ or speedprofiles/. This needs py7zr 1.1 or
# later; the read()/readall() of older versions no longer exist.
#
#   python batch\ExtractTomTomEdition.py <delivery.zip> <file_date> [--countries nld,bel] [--dry-run]
#
# Example (a delivery to PBL, edition 2025.12.000, NL and BE):
#   python batch\ExtractTomTomEdition.py "F:\SourceData\NetworkModel_PBL_priv\TomtomMultinet_2025_copyright.zip" yr2025_12 --countries nld,bel
#
# Requires py7zr (pip install --user py7zr).
import sys, os, re, io, gzip, argparse, zipfile, tempfile, time
import py7zr

PRIV = r"F:\SourceData\NetworkModel_PBL_priv"

class GunzipWriter(io.BytesIO):
    """Receives an archive member in memory and writes it, gunzipped, to disk at close().
    py7zr's MemIO calls seek(0) and close() when the member is complete; the data is then in
    the buffer. A member other than .gz is written unchanged."""
    def __init__(self, target: str, counter: list):
        super().__init__()
        self.target = target
        self.counter = counter
        self._done = False

    def size(self) -> int:
        return len(self.getbuffer())

    def close(self) -> None:
        if not self._done:
            self._done = True
            data = self.getvalue()
            out = self.target
            if out.lower().endswith(".gz"):
                out = out[:-3]
                data = gzip.decompress(data)
            if os.path.exists(out) and os.path.getsize(out) != len(data):
                raise RuntimeError(f"name conflict: {out} already exists with different content")
            os.makedirs(os.path.dirname(out), exist_ok=True)
            with open(out, "wb") as f:
                f.write(data)
            self.counter[0] += 1
        super().close()

class GunzipFactory(py7zr.WriterFactory):
    """The factory hook of py7zr >= 1.1: one writer per member. filename is the sanitised full
    path (leading '/' stripped) including the folders inside the archive; only the
    file name is kept, FLAT in the target folder (see point 3 in the header)."""
    def __init__(self, flat_dir: str):
        self.flat_dir = flat_dir
        self.counter = [0]

    def create(self, filename: str):
        return GunzipWriter(os.path.join(self.flat_dir, os.path.basename(filename)), self.counter)

def extract_volume(zf, entry, flat_dir):
    """Extracts one .7z.001 volume from the zip FLAT to flat_dir, gunzipped; returns the number of files."""
    with tempfile.NamedTemporaryFile(suffix=".7z", delete=False) as tmp:
        with zf.open(entry) as src:
            while True:
                b = src.read(16 * 1024 * 1024)
                if not b:
                    break
                tmp.write(b)
        tmp_path = tmp.name
    factory = GunzipFactory(flat_dir)
    try:
        with py7zr.SevenZipFile(tmp_path, mode="r") as arch:
            arch.extractall(path=flat_dir, factory=factory)
    finally:
        try:
            os.remove(tmp_path)
        except OSError:
            pass
    return factory.counter[0]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("zip")
    ap.add_argument("file_date", help="folder name as the preset names it, for example yr2025_12")
    ap.add_argument("--countries", default="nld", help="comma-separated list of country codes in the archive names (nld, bel)")
    ap.add_argument("--priv", default=PRIV)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    countries = [c.strip().lower() for c in a.countries.split(",") if c.strip()]
    root = os.path.join(a.priv, "TomTom", a.file_date)

    pat_mn = re.compile(r"shpa-mn-(%s)-" % "|".join(countries))
    pat_sp = re.compile(r"shpd-sp-(%s)-" % "|".join(countries))

    with zipfile.ZipFile(a.zip) as z:
        jobs, docs = [], []
        for e in z.infolist():
            if e.is_dir():
                continue
            name = os.path.basename(e.filename)
            fn = e.filename.replace("\\", "/")
            if "Documentation" in fn or "/doc/" in fn or "/Info/" in fn:
                docs.append(e)
            elif pat_mn.search(name):
                jobs.append((e, os.path.join(root, "multinet")))
            elif pat_sp.search(name):
                jobs.append((e, os.path.join(root, "speedprofiles")))
        total = sum(e.file_size for e, _ in jobs)
        print(f"{len(jobs)} data archives ({total/1e6:,.0f} MB compressed) + {len(docs)} documentation files -> {root}")
        for e, dst in jobs:
            print(f"  {e.file_size/1e6:8,.1f} MB  {os.path.basename(e.filename)}  ->  {os.path.relpath(dst, root)}")
        if a.dry_run:
            return
        t0 = time.time()
        for i, (e, dst) in enumerate(jobs, 1):
            n = extract_volume(z, e, dst)
            print(f"[{i}/{len(jobs)}] {os.path.basename(e.filename)} -> {n} files  ({time.time()-t0:,.0f} s)", flush=True)
        # Copy the documentation unchanged (7z volumes and pdf files), as in the edition folder yr2021_12/doc.
        docdir = os.path.join(root, "doc")
        os.makedirs(docdir, exist_ok=True)
        for e in docs:
            out = os.path.join(docdir, os.path.basename(e.filename))
            with z.open(e) as src, open(out, "wb") as f:
                while True:
                    b = src.read(16 * 1024 * 1024)
                    if not b:
                        break
                    f.write(b)
        print(f"documentation: {len(docs)} files -> {docdir}")
        shp = sum(1 for _, _, fs in os.walk(os.path.join(root, "multinet")) for f in fs if f.lower().endswith(".shp"))
        dbf = sum(1 for _, _, fs in os.walk(os.path.join(root, "speedprofiles")) for f in fs if f.lower().endswith(".dbf"))
        gz  = sum(1 for _, _, fs in os.walk(root) for f in fs if f.lower().endswith(".gz"))
        print(f"done: {shp} .shp under multinet/, {dbf} .dbf under speedprofiles/, {gz} .gz left over (should be 0)")

if __name__ == "__main__":
    main()
