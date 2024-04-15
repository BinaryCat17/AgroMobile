-- DROP TABLE IF EXISTS points;
-- DROP TABLE IF EXISTS polys;
-- DROP TABLE IF EXISTS geopoly;
-- DROP TABLE IF EXISTS tg;
-- DROP TRIGGER IF EXISTS aftInsT1;
-- DROP TRIGGER IF EXISTS aftInsT2;
-- DROP TABLE IF EXISTS TypesOfPlants;
-- DROP TABLE IF EXISTS WorkYears;
-- DROP TABLE IF EXISTS FieldPlants;

-- Geo Info;

CREATE VIRTUAL TABLE IF NOT EXISTS tg USING geopoly (
    t_id -- references geopoints(id) or polys(id)
) ;

CREATE TABLE IF NOT EXISTS points (
    id varchar(500) PRIMARY KEY,
    longitude REAL,
    latitude REAL,
    desc TEXT,
    validGeo BOOLEAN GENERATED ALWAYS AS (
        typeof(longitude) = 'real' AND
        abs(longitude) <= 180 AND
        typeof(latitude) = 'real' AND
        abs(latitude) < 90
    ) STORED
) ;

CREATE TABLE IF NOT EXISTS polys (
    id varchar(500) PRIMARY KEY,
    shape TEXT,
    desc TEXT
) ;

CREATE TRIGGER IF NOT EXISTS aftInsT1
    AFTER INSERT ON points
    WHEN new.validGeo = 1
BEGIN
INSERT INTO tg (
            _shape,
            t_id
        )
        VALUES (
            geopoly_bbox(
                geopoly_regular(
                    new.longitude,
                    new.latitude,
                    abs(5/(40075017*cos(new.latitude)/360)),
                    4
                )
            ),
            new.id
        );
END ;

CREATE TRIGGER IF NOT EXISTS aftInsT2
    AFTER INSERT ON polys
BEGIN
INSERT INTO tg (
         t_id,
         _shape
     )
     VALUES (
        NEW.id,
        NEW.shape
     );
END ;

-- Docs info;

CREATE TABLE IF NOT EXISTS TypesOfPlants (
    id varchar(500) PRIMARY KEY,
    name TEXT UNIQUE
) ;

CREATE TABLE IF NOT EXISTS WorkYears (
    id varchar(500) PRIMARY KEY,
    name TEXT UNIQUE
) ;

CREATE TABLE IF NOT EXISTS FieldPlants (
    id varchar(500) PRIMARY KEY,
    region varchar(500) REFERENCES polys(id),
    workYear varchar(500) REFERENCES WorkYears(id),
    plant varchar(500) REFERENCES TypesOfPlants(id)
) ;
