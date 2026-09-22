# Richt een TomTom-editiemap in zoals cfg/main/SourceData/TomTom.dms die leest:
#
#   %NetworkModel_PrivDir%/TomTom/<file_date>/multinet/*.shp       (MultiNet-tegels, plat)
#   %NetworkModel_PrivDir%/TomTom/<file_date>/speedprofiles/*.dbf  (speed profiles, plat)
#   %NetworkModel_PrivDir%/TomTom/<file_date>/doc/                 (documentatie, ongewijzigd)
#
# uit een TomTom-levering als zip van .7z.001-volumes. Drie eigenaardigheden dwingen tot een
# eigen writer in plaats van een kaal py7zr.extractall():
#   1. de archiefnamen beginnen met een '/' ('/eur2025_12_000/shpa/mn/nld/ax/...'); de gewone
#      schrijfroute van py7zr 1.1 struikelt daarover in zijn padcontrole ("Specified path is
#      bad"), de factory-route niet (de sanitizer stript de slash en MemIO slaat de controle over);
#   2. elk shapefile-onderdeel is apart gegzipt ('..._a7.shp.gz'); de reader wil .shp/.dbf;
#   3. de reader wil multinet/ en speedprofiles/ PLAT: de shape-type-sniff in TomTom.dms
#      (`file_str_values`, StorageType "strfiles", StorageName "=first(FolderName)") plakt de map
#      van het EERSTE bestand voor elke bestandsnaam, dus bestanden in submappen worden niet
#      gevonden (_fsopen faalt). Submappen per archief zijn ook niet nodig: TomTom-namen dragen
#      de tegelcode (belbe210000______nw.shp), dus ze botsen niet; dat wordt wel gecontroleerd.
# Dus: extractall() met een WriterFactory die per lid in het geheugen ontvangt, gunzipt en
# als kale bestandsnaam in multinet/ resp. speedprofiles/ wegschrijft. py7zr < 1.1 kende nog
# read()/readall(); die zijn weg.
#
#   python batch\ExtractTomTomEdition.py <levering.zip> <file_date> [--countries nld,bel] [--dry-run]
#
# Voorbeeld (Marnix Breedijk, PBL, editie 2025.12.000, NL en BE):
#   python batch\ExtractTomTomEdition.py "F:\SourceData\NetworkModel_PBL_priv\TomtomMultinet_2025_copyright.zip" yr2025_12 --countries nld,bel
#
# Vereist py7zr (pip install --user py7zr).
import sys, os, re, io, gzip, argparse, zipfile, tempfile, time
import py7zr

PRIV = r"F:\SourceData\NetworkModel_PBL_priv"

class GunzipWriter(io.BytesIO):
    """Ontvangt een archieflid in het geheugen en schrijft het bij close() gunzipt naar schijf.
    py7zr's MemIO roept seek(0) en close() aan als het lid compleet is; de data staat dan in
    de buffer. Een ander lid dan .gz wordt ongewijzigd weggeschreven."""
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
                raise RuntimeError(f"naamconflict: {out} bestaat al met een andere inhoud")
            os.makedirs(os.path.dirname(out), exist_ok=True)
            with open(out, "wb") as f:
                f.write(data)
            self.counter[0] += 1
        super().close()

class GunzipFactory(py7zr.WriterFactory):
    """De factory-haak van py7zr >= 1.1: per lid een writer. fname is het gesaneerde volledige
    pad (leading '/' gestript) inclusief de archief-interne mappen; daarvan blijft alleen de
    bestandsnaam over, PLAT in de doelmap (zie punt 3 in de kop)."""
    def __init__(self, flat_dir: str):
        self.flat_dir = flat_dir
        self.counter = [0]

    def create(self, filename: str):
        return GunzipWriter(os.path.join(self.flat_dir, os.path.basename(filename)), self.counter)

def extract_volume(zf, entry, flat_dir):
    """Een .7z.001-volume uit de zip PLAT naar flat_dir, gegunzipt. Geeft #bestanden."""
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
    ap.add_argument("file_date", help="mapnaam zoals de preset hem noemt, bv. yr2025_12")
    ap.add_argument("--countries", default="nld", help="komma-lijst van landcodes in de archiefnamen (nld, bel)")
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
        print(f"{len(jobs)} data-archieven ({total/1e6:,.0f} MB gecomprimeerd) + {len(docs)} documentatiebestanden -> {root}")
        for e, dst in jobs:
            print(f"  {e.file_size/1e6:8,.1f} MB  {os.path.basename(e.filename)}  ->  {os.path.relpath(dst, root)}")
        if a.dry_run:
            return
        t0 = time.time()
        for i, (e, dst) in enumerate(jobs, 1):
            n = extract_volume(z, e, dst)
            print(f"[{i}/{len(jobs)}] {os.path.basename(e.filename)} -> {n} bestanden  ({time.time()-t0:,.0f} s)", flush=True)
        # documentatie ongewijzigd meenemen (7z-volumes en pdf's), net als Jips yr2021_12/doc
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
        print(f"documentatie: {len(docs)} bestanden -> {docdir}")
        shp = sum(1 for _, _, fs in os.walk(os.path.join(root, "multinet")) for f in fs if f.lower().endswith(".shp"))
        dbf = sum(1 for _, _, fs in os.walk(os.path.join(root, "speedprofiles")) for f in fs if f.lower().endswith(".dbf"))
        gz  = sum(1 for _, _, fs in os.walk(root) for f in fs if f.lower().endswith(".gz"))
        print(f"klaar: {shp} .shp onder multinet/, {dbf} .dbf onder speedprofiles/, {gz} .gz achtergebleven (hoort 0)")

if __name__ == "__main__":
    main()
