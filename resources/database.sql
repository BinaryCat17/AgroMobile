-- DROP TABLE IF EXISTS Organizations ;
-- DROP TABLE IF EXISTS geopoly ;
-- DROP TABLE IF EXISTS LocationsDocuments ;
-- DROP TABLE IF EXISTS LocationsRecords ;
-- DROP TRIGGER IF EXISTS aftInsLocations ;
-- DROP TRIGGER IF EXISTS aftDelLocations ;
-- DROP TABLE IF EXISTS RegionsDocuments ;
-- DROP TABLE IF EXISTS RegionsRecords ;
-- DROP TRIGGER IF EXISTS aftInsRegions ;
-- DROP TRIGGER IF EXISTS aftDelRegions ;
-- DROP TABLE IF EXISTS WorkYearsDocuments ;
-- DROP TABLE IF EXISTS WorkYearsRecords ;
-- DROP TABLE IF EXISTS PlantsTypesDocuments ;
-- DROP TABLE IF EXISTS PlantTypesRecords ;
-- DROP TABLE IF EXISTS PlantVarietiesDocuments ;
-- DROP TABLE IF EXISTS PlantVarietiesRecords ;
-- DROP TABLE IF EXISTS FieldPlantsDocuments ;
-- DROP TABLE IF EXISTS FieldPlantsRecords ;


-- Base --------------------------------------------------------------------------------------------------------;

CREATE TABLE IF NOT EXISTS Organizations (
    id UUID PRIMARY KEY,
    name TEXT
) ;

-- Geo ---------------------------------------------------------------------------------------------------------;

CREATE VIRTUAL TABLE IF NOT EXISTS tg USING geopoly (
    t_id -- references LocationsRecords(id) or RegionsRecords(id)
) ;

CREATE TABLE IF NOT EXISTS LocationsDocuments (
    id varchar(500) PRIMARY KEY,
    name TEXT,
    created_at TEXT,
    organization_id REFERENCES Organizations(id)
) ;

CREATE TABLE IF NOT EXISTS LocationsRecords (
    id varchar(500) PRIMARY KEY,
    doc_id varchar(500) REFERENCES PointsDocuments(id),
    name TEXT,
    pos_longitude REAL,
    pos_latitude REAL,
    validGeo BOOLEAN GENERATED ALWAYS AS (
        typeof(pos_longitude) = 'real' AND
        abs(pos_longitude) <= 180 AND
        typeof(pos_latitude) = 'real' AND
        abs(pos_latitude) < 90
    ) STORED
) ;

CREATE TRIGGER IF NOT EXISTS aftInsLocations
    AFTER INSERT ON LocationsRecords
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

CREATE TRIGGER IF NOT EXISTS aftDelLocations
    AFTER DELETE ON LocationsRecords
BEGIN
    DELETE FROM tg WHERE t_id = OLD.id;
END ;

CREATE TABLE IF NOT EXISTS RegionsDocuments (
    id varchar(500) PRIMARY KEY,
    name TEXT,
    created_at TEXT,
    organization_id REFERENCES Organizations(id)
) ;

CREATE TABLE IF NOT EXISTS RegionsRecords (
    id varchar(500) PRIMARY KEY,
    doc_id varchar(500) REFERENCES RegionsDocuments(id),
    name TEXT,
    shape TEXT
) ;

CREATE TRIGGER IF NOT EXISTS aftInsRegions
    AFTER INSERT ON RegionsRecords
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

CREATE TRIGGER IF NOT EXISTS aftDelRegions
    AFTER DELETE ON RegionsRecords
BEGIN
    DELETE FROM tg WHERE t_id = OLD.id;
END ;

-- Docs --------------------------------------------------------------------------------------------------------;

CREATE TABLE IF NOT EXISTS WorkYearsDocuments (
    id varchar(500) PRIMARY KEY,
    name TEXT,
    created_at TEXT,
    organization_id REFERENCES Organizations(id)
) ;

CREATE TABLE IF NOT EXISTS WorkYearsRecords (
    id varchar(500) PRIMARY KEY,
    doc_id varchar(500) REFERENCES WorkYearsDocuments(id),
    name TEXT
) ;

CREATE TABLE IF NOT EXISTS PlantsTypesDocuments (
    id varchar(500) PRIMARY KEY,
    name TEXT,
    created_at TEXT,
    organization_id REFERENCES Organizations(id)
) ;

CREATE TABLE IF NOT EXISTS PlantTypesRecords (
    id varchar(500) PRIMARY KEY,
    doc_id varchar(500) REFERENCES PlantsTypesDocuments(id),
    name TEXT,
    color TEXT
) ;

CREATE TABLE IF NOT EXISTS PlantVarietiesDocuments (
    id varchar(500) PRIMARY KEY,
    name TEXT,
    created_at TEXT,
    organization_id REFERENCES Organizations(id),
    plant_type_id UUID REFERENCES PlantTypesRecords(id)
) ;

CREATE TABLE IF NOT EXISTS PlantVarietiesRecords (
    id varchar(500) PRIMARY KEY,
    doc_id varchar(500) REFERENCES PlantVarietiesDocuments(id),
    name TEXT
) ;

CREATE TABLE IF NOT EXISTS FieldPlantsDocuments (
    id varchar(500) PRIMARY KEY,
    name TEXT,
    created_at TEXT,
    organization_id REFERENCES Organizations(id),
    workYear_id REFERENCES WorkYearsRecords(id)
) ;

CREATE TABLE IF NOT EXISTS FieldPlantsRecords (
    id varchar(500) PRIMARY KEY,
    doc_id varchar(500) REFERENCES WorkYearsDocuments(id),
    name TEXT,
    region_id varchar(500) REFERENCES RegionsRecords(id),
    plant_variety_id varchar(500) REFERENCES PlantVarietiesRecords(id)
) ;