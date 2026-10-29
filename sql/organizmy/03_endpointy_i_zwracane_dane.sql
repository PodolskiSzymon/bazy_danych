-- Organizm 3: Endpointy i zwracane dane
-- Jakie konkretne zapytania ma API i jakie pola zwraca każde z nich.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG03_HTTPMethod (
    HTTPMethodKey   NUMBER(2)     NOT NULL,
    HTTPMethodName  VARCHAR2(10)  NOT NULL
);

CREATE TABLE ORG03_DataSubject (
    DataSubjectKey   NUMBER(2)     NOT NULL,
    DataSubjectName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG03_APIEndpoint (
    APIEndpointKey       NUMBER(6)      NOT NULL,
    APIVersionKey        NUMBER(4)      NOT NULL,
    HTTPMethodKey        NUMBER(2)      NOT NULL,
    DataSubjectKey       NUMBER(2)      NOT NULL,
    EndpointPath         VARCHAR2(200)  NOT NULL,
    IsPaginated          CHAR(1)        NOT NULL,
    EndpointDescription  VARCHAR2(300)
);

CREATE TABLE ORG03_EndpointResponse (
    EndpointResponseKey  NUMBER(7)      NOT NULL,
    APIEndpointKey       NUMBER(6)      NOT NULL,
    HTTPStatusCode       NUMBER(3)      NOT NULL,
    DataFormatKey        NUMBER(2)      NOT NULL,
    IsErrorResponse      CHAR(1)        NOT NULL,
    ResponseDescription  VARCHAR2(200)
);

CREATE TABLE ORG03_FieldDataType (
    FieldDataTypeKey   NUMBER(2)     NOT NULL,
    FieldDataTypeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG03_EndpointData (
    EndpointDataKey        NUMBER(8)      NOT NULL,
    EndpointResponseKey    NUMBER(7)      NOT NULL,
    ParentEndpointDataKey  NUMBER(8),
    DataName               VARCHAR2(50)   NOT NULL,
    DataPath               VARCHAR2(200)  NOT NULL,
    FieldDataTypeKey       NUMBER(2)      NOT NULL,
    IsRequired             CHAR(1)        NOT NULL,
    ExampleValue           VARCHAR2(200)
);

CREATE TABLE ORG03_CanonicalField (
    CanonicalFieldKey          NUMBER(4)      NOT NULL,
    CanonicalFieldName         VARCHAR2(60)   NOT NULL,
    DataSubjectKey             NUMBER(2)      NOT NULL,
    CanonicalFieldDescription  VARCHAR2(300)
);

CREATE TABLE ORG03_FieldMapping (
    FieldMappingKey     NUMBER(8)      NOT NULL,
    EndpointDataKey     NUMBER(8)      NOT NULL,
    CanonicalFieldKey   NUMBER(4)      NOT NULL,
    TransformationRule  VARCHAR2(300)
);

COMMENT ON TABLE ORG03_HTTPMethod IS 'Metoda HTTP endpointu.';
COMMENT ON COLUMN ORG03_HTTPMethod.HTTPMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_HTTPMethod.HTTPMethodName IS 'Nazwa metody';

COMMENT ON TABLE ORG03_DataSubject IS 'Czego dotyczą dane z endpointu – łączy endpointy z dalszymi organizmami.';
COMMENT ON COLUMN ORG03_DataSubject.DataSubjectKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_DataSubject.DataSubjectName IS 'Nazwa rodzaju danych';

COMMENT ON TABLE ORG03_APIEndpoint IS 'Jedno zapytanie w danej wersji API.';
COMMENT ON COLUMN ORG03_APIEndpoint.APIEndpointKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_APIEndpoint.APIVersionKey IS 'Wersja API';
COMMENT ON COLUMN ORG03_APIEndpoint.HTTPMethodKey IS 'Metoda HTTP';
COMMENT ON COLUMN ORG03_APIEndpoint.DataSubjectKey IS 'Czego dotyczą zwracane dane';
COMMENT ON COLUMN ORG03_APIEndpoint.EndpointPath IS 'Ścieżka, np. /v2/jobs';
COMMENT ON COLUMN ORG03_APIEndpoint.IsPaginated IS 'Czy wyniki są dzielone na strony';
COMMENT ON COLUMN ORG03_APIEndpoint.EndpointDescription IS 'Co robi endpoint';

COMMENT ON TABLE ORG03_EndpointResponse IS 'Jedna możliwa odpowiedź endpointu: kod HTTP i format.';
COMMENT ON COLUMN ORG03_EndpointResponse.EndpointResponseKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_EndpointResponse.APIEndpointKey IS 'Endpoint';
COMMENT ON COLUMN ORG03_EndpointResponse.HTTPStatusCode IS 'Kod odpowiedzi HTTP, np. 200, 404, 429';
COMMENT ON COLUMN ORG03_EndpointResponse.DataFormatKey IS 'Format tej odpowiedzi';
COMMENT ON COLUMN ORG03_EndpointResponse.IsErrorResponse IS 'Czy to odpowiedź z błędem';
COMMENT ON COLUMN ORG03_EndpointResponse.ResponseDescription IS 'Kiedy pojawia się ta odpowiedź';

COMMENT ON TABLE ORG03_FieldDataType IS 'Typ danych pola w odpowiedzi.';
COMMENT ON COLUMN ORG03_FieldDataType.FieldDataTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_FieldDataType.FieldDataTypeName IS 'Nazwa typu';

COMMENT ON TABLE ORG03_EndpointData IS 'Jedno pole w odpowiedzi endpointu – odpowiednik PlatformAPIData ze schematu z zajęć.';
COMMENT ON COLUMN ORG03_EndpointData.EndpointDataKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_EndpointData.EndpointResponseKey IS 'Odpowiedź, w której jest pole';
COMMENT ON COLUMN ORG03_EndpointData.ParentEndpointDataKey IS 'Pole nadrzędne, gdy pole jest zagnieżdżone';
COMMENT ON COLUMN ORG03_EndpointData.DataName IS 'Nazwa pola u platformy, np. salary_from';
COMMENT ON COLUMN ORG03_EndpointData.DataPath IS 'Pełna ścieżka pola, np. salary.from';
COMMENT ON COLUMN ORG03_EndpointData.FieldDataTypeKey IS 'Typ danych pola';
COMMENT ON COLUMN ORG03_EndpointData.IsRequired IS 'Czy platforma zawsze podaje to pole';
COMMENT ON COLUMN ORG03_EndpointData.ExampleValue IS 'Przykładowa wartość';

COMMENT ON TABLE ORG03_CanonicalField IS 'Nasza jedna nazwa danej, niezależna od platformy.';
COMMENT ON COLUMN ORG03_CanonicalField.CanonicalFieldKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_CanonicalField.CanonicalFieldName IS 'Nazwa, np. „Wynagrodzenie od”';
COMMENT ON COLUMN ORG03_CanonicalField.DataSubjectKey IS 'Czego dotyczy';
COMMENT ON COLUMN ORG03_CanonicalField.CanonicalFieldDescription IS 'Opis';

COMMENT ON TABLE ORG03_FieldMapping IS 'Przypisanie pola platformy do naszej nazwy, z regułą przeliczenia.';
COMMENT ON COLUMN ORG03_FieldMapping.FieldMappingKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG03_FieldMapping.EndpointDataKey IS 'Pole platformy';
COMMENT ON COLUMN ORG03_FieldMapping.CanonicalFieldKey IS 'Nasza nazwa';
COMMENT ON COLUMN ORG03_FieldMapping.TransformationRule IS 'Jak przeliczyć wartość, np. „grosze na złote: /100”';

ALTER TABLE ORG03_HTTPMethod ADD CONSTRAINT ORG03_HTTPMethod_PK PRIMARY KEY (HTTPMethodKey);
ALTER TABLE ORG03_HTTPMethod ADD CONSTRAINT ORG03_HTTPMethod_HTTPMethodName_UN UNIQUE (HTTPMethodName);
ALTER TABLE ORG03_DataSubject ADD CONSTRAINT ORG03_DataSubject_PK PRIMARY KEY (DataSubjectKey);
ALTER TABLE ORG03_DataSubject ADD CONSTRAINT ORG03_DataSubject_DataSubjectName_UN UNIQUE (DataSubjectName);
ALTER TABLE ORG03_APIEndpoint ADD CONSTRAINT ORG03_APIEndpoint_PK PRIMARY KEY (APIEndpointKey);
ALTER TABLE ORG03_APIEndpoint ADD CONSTRAINT ORG03_APIEndpoint_UN UNIQUE (APIVersionKey, HTTPMethodKey, EndpointPath);
ALTER TABLE ORG03_APIEndpoint ADD CONSTRAINT ORG03_APIEndpoint_IsPaginated_CK CHECK (IsPaginated IN ('T', 'N'));
ALTER TABLE ORG03_EndpointResponse ADD CONSTRAINT ORG03_EndpointResponse_PK PRIMARY KEY (EndpointResponseKey);
ALTER TABLE ORG03_EndpointResponse ADD CONSTRAINT ORG03_EndpointResponse_UN UNIQUE (APIEndpointKey, HTTPStatusCode, DataFormatKey);
ALTER TABLE ORG03_EndpointResponse ADD CONSTRAINT ORG03_EndpointResponse_IsErrorResponse_CK CHECK (IsErrorResponse IN ('T', 'N'));
ALTER TABLE ORG03_EndpointResponse ADD CONSTRAINT ORG03_EndpointResponse_CK1 CHECK (HTTPStatusCode BETWEEN 100 AND 599);
ALTER TABLE ORG03_FieldDataType ADD CONSTRAINT ORG03_FieldDataType_PK PRIMARY KEY (FieldDataTypeKey);
ALTER TABLE ORG03_FieldDataType ADD CONSTRAINT ORG03_FieldDataType_FieldDataTypeName_UN UNIQUE (FieldDataTypeName);
ALTER TABLE ORG03_EndpointData ADD CONSTRAINT ORG03_EndpointData_PK PRIMARY KEY (EndpointDataKey);
ALTER TABLE ORG03_EndpointData ADD CONSTRAINT ORG03_EndpointData_UN UNIQUE (EndpointResponseKey, DataPath);
ALTER TABLE ORG03_EndpointData ADD CONSTRAINT ORG03_EndpointData_IsRequired_CK CHECK (IsRequired IN ('T', 'N'));
ALTER TABLE ORG03_CanonicalField ADD CONSTRAINT ORG03_CanonicalField_PK PRIMARY KEY (CanonicalFieldKey);
ALTER TABLE ORG03_CanonicalField ADD CONSTRAINT ORG03_CanonicalField_CanonicalFieldName_UN UNIQUE (CanonicalFieldName);
ALTER TABLE ORG03_FieldMapping ADD CONSTRAINT ORG03_FieldMapping_PK PRIMARY KEY (FieldMappingKey);
ALTER TABLE ORG03_FieldMapping ADD CONSTRAINT ORG03_FieldMapping_UN UNIQUE (EndpointDataKey, CanonicalFieldKey);

ALTER TABLE ORG03_APIEndpoint ADD CONSTRAINT ORG03_APIEndpoint_HTTPMethod_FK FOREIGN KEY (HTTPMethodKey) REFERENCES ORG03_HTTPMethod (HTTPMethodKey);
ALTER TABLE ORG03_APIEndpoint ADD CONSTRAINT ORG03_APIEndpoint_DataSubject_FK FOREIGN KEY (DataSubjectKey) REFERENCES ORG03_DataSubject (DataSubjectKey);
ALTER TABLE ORG03_EndpointResponse ADD CONSTRAINT ORG03_EndpointResponse_APIEndpoint_FK FOREIGN KEY (APIEndpointKey) REFERENCES ORG03_APIEndpoint (APIEndpointKey);
ALTER TABLE ORG03_EndpointData ADD CONSTRAINT ORG03_EndpointData_EndpointResponse_FK FOREIGN KEY (EndpointResponseKey) REFERENCES ORG03_EndpointResponse (EndpointResponseKey);
ALTER TABLE ORG03_EndpointData ADD CONSTRAINT ORG03_EndpointData_EndpointData_FK FOREIGN KEY (ParentEndpointDataKey) REFERENCES ORG03_EndpointData (EndpointDataKey);
ALTER TABLE ORG03_EndpointData ADD CONSTRAINT ORG03_EndpointData_FieldDataType_FK FOREIGN KEY (FieldDataTypeKey) REFERENCES ORG03_FieldDataType (FieldDataTypeKey);
ALTER TABLE ORG03_CanonicalField ADD CONSTRAINT ORG03_CanonicalField_DataSubject_FK FOREIGN KEY (DataSubjectKey) REFERENCES ORG03_DataSubject (DataSubjectKey);
ALTER TABLE ORG03_FieldMapping ADD CONSTRAINT ORG03_FieldMapping_EndpointData_FK FOREIGN KEY (EndpointDataKey) REFERENCES ORG03_EndpointData (EndpointDataKey);
ALTER TABLE ORG03_FieldMapping ADD CONSTRAINT ORG03_FieldMapping_CanonicalField_FK FOREIGN KEY (CanonicalFieldKey) REFERENCES ORG03_CanonicalField (CanonicalFieldKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG03_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (1, 'GET');
INSERT INTO ORG03_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (2, 'POST');
INSERT INTO ORG03_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (3, 'PUT');
INSERT INTO ORG03_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (4, 'PATCH');
INSERT INTO ORG03_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (5, 'DELETE');
INSERT INTO ORG03_DataSubject (DataSubjectKey, DataSubjectName) VALUES (1, 'Konto firmy');
INSERT INTO ORG03_DataSubject (DataSubjectKey, DataSubjectName) VALUES (2, 'Ogłoszenie');
INSERT INTO ORG03_DataSubject (DataSubjectKey, DataSubjectName) VALUES (3, 'Zdarzenie ogłoszenia');
INSERT INTO ORG03_DataSubject (DataSubjectKey, DataSubjectName) VALUES (4, 'Aplikacja kandydata');
INSERT INTO ORG03_DataSubject (DataSubjectKey, DataSubjectName) VALUES (5, 'Status aplikacji');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (1, 'Tekst');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (2, 'Liczba całkowita');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (3, 'Liczba dziesiętna');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (4, 'Prawda / fałsz');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (5, 'Data');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (6, 'Data i godzina');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (7, 'Lista');
INSERT INTO ORG03_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (8, 'Obiekt');
INSERT INTO ORG03_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (1, 'Wynagrodzenie od', 2, 'Dolna granica widełek');
INSERT INTO ORG03_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (2, 'Rodzaj umowy', 2, NULL);
INSERT INTO ORG03_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (3, 'NIP firmy', 1, 'NIP wpisany w koncie firmy');
INSERT INTO ORG03_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (4, 'Data aplikacji', 4, NULL);
COMMIT;
