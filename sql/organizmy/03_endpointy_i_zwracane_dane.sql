-- Organizm 3: Endpointy i zwracane dane
-- Jakie konkretne zapytania ma API i jakie pola zwraca każde z nich.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE HTTPMethod (
    HTTPMethodKey   NUMBER(2)     NOT NULL,
    HTTPMethodName  VARCHAR2(10)  NOT NULL
);

CREATE TABLE DataSubject (
    DataSubjectKey   NUMBER(2)     NOT NULL,
    DataSubjectName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE APIEndpoint (
    APIEndpointKey       NUMBER(6)      NOT NULL,
    APIVersionKey        NUMBER(4)      NOT NULL,
    HTTPMethodKey        NUMBER(2)      NOT NULL,
    DataSubjectKey       NUMBER(2)      NOT NULL,
    EndpointPath         VARCHAR2(200)  NOT NULL,
    IsPaginated          CHAR(1)        NOT NULL,
    EndpointDescription  VARCHAR2(300)
);

CREATE TABLE EndpointResponse (
    EndpointResponseKey  NUMBER(7)      NOT NULL,
    APIEndpointKey       NUMBER(6)      NOT NULL,
    HTTPStatusCode       NUMBER(3)      NOT NULL,
    DataFormatKey        NUMBER(2)      NOT NULL,
    IsErrorResponse      CHAR(1)        NOT NULL,
    ResponseDescription  VARCHAR2(200)
);

CREATE TABLE FieldDataType (
    FieldDataTypeKey   NUMBER(2)     NOT NULL,
    FieldDataTypeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE EndpointData (
    EndpointDataKey        NUMBER(8)      NOT NULL,
    EndpointResponseKey    NUMBER(7)      NOT NULL,
    ParentEndpointDataKey  NUMBER(8),
    DataName               VARCHAR2(50)   NOT NULL,
    DataPath               VARCHAR2(200)  NOT NULL,
    FieldDataTypeKey       NUMBER(2)      NOT NULL,
    IsRequired             CHAR(1)        NOT NULL,
    ExampleValue           VARCHAR2(200)
);

CREATE TABLE CanonicalField (
    CanonicalFieldKey          NUMBER(4)      NOT NULL,
    CanonicalFieldName         VARCHAR2(60)   NOT NULL,
    DataSubjectKey             NUMBER(2)      NOT NULL,
    CanonicalFieldDescription  VARCHAR2(300)
);

CREATE TABLE FieldMapping (
    FieldMappingKey     NUMBER(8)      NOT NULL,
    EndpointDataKey     NUMBER(8)      NOT NULL,
    CanonicalFieldKey   NUMBER(4)      NOT NULL,
    TransformationRule  VARCHAR2(300)
);

COMMENT ON TABLE HTTPMethod IS 'Metoda HTTP endpointu.';
COMMENT ON COLUMN HTTPMethod.HTTPMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN HTTPMethod.HTTPMethodName IS 'Nazwa metody';

COMMENT ON TABLE DataSubject IS 'Czego dotyczą dane z endpointu – łączy endpointy z dalszymi organizmami.';
COMMENT ON COLUMN DataSubject.DataSubjectKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN DataSubject.DataSubjectName IS 'Nazwa rodzaju danych';

COMMENT ON TABLE APIEndpoint IS 'Jedno zapytanie w danej wersji API.';
COMMENT ON COLUMN APIEndpoint.APIEndpointKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN APIEndpoint.APIVersionKey IS 'Wersja API';
COMMENT ON COLUMN APIEndpoint.HTTPMethodKey IS 'Metoda HTTP';
COMMENT ON COLUMN APIEndpoint.DataSubjectKey IS 'Czego dotyczą zwracane dane';
COMMENT ON COLUMN APIEndpoint.EndpointPath IS 'Ścieżka, np. /v2/jobs';
COMMENT ON COLUMN APIEndpoint.IsPaginated IS 'Czy wyniki są dzielone na strony';
COMMENT ON COLUMN APIEndpoint.EndpointDescription IS 'Co robi endpoint';

COMMENT ON TABLE EndpointResponse IS 'Jedna możliwa odpowiedź endpointu: kod HTTP i format.';
COMMENT ON COLUMN EndpointResponse.EndpointResponseKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EndpointResponse.APIEndpointKey IS 'Endpoint';
COMMENT ON COLUMN EndpointResponse.HTTPStatusCode IS 'Kod odpowiedzi HTTP, np. 200, 404, 429';
COMMENT ON COLUMN EndpointResponse.DataFormatKey IS 'Format tej odpowiedzi';
COMMENT ON COLUMN EndpointResponse.IsErrorResponse IS 'Czy to odpowiedź z błędem';
COMMENT ON COLUMN EndpointResponse.ResponseDescription IS 'Kiedy pojawia się ta odpowiedź';

COMMENT ON TABLE FieldDataType IS 'Typ danych pola w odpowiedzi.';
COMMENT ON COLUMN FieldDataType.FieldDataTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN FieldDataType.FieldDataTypeName IS 'Nazwa typu';

COMMENT ON TABLE EndpointData IS 'Jedno pole w odpowiedzi endpointu – odpowiednik PlatformAPIData ze schematu z zajęć.';
COMMENT ON COLUMN EndpointData.EndpointDataKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EndpointData.EndpointResponseKey IS 'Odpowiedź, w której jest pole';
COMMENT ON COLUMN EndpointData.ParentEndpointDataKey IS 'Pole nadrzędne, gdy pole jest zagnieżdżone';
COMMENT ON COLUMN EndpointData.DataName IS 'Nazwa pola u platformy, np. salary_from';
COMMENT ON COLUMN EndpointData.DataPath IS 'Pełna ścieżka pola, np. salary.from';
COMMENT ON COLUMN EndpointData.FieldDataTypeKey IS 'Typ danych pola';
COMMENT ON COLUMN EndpointData.IsRequired IS 'Czy platforma zawsze podaje to pole';
COMMENT ON COLUMN EndpointData.ExampleValue IS 'Przykładowa wartość';

COMMENT ON TABLE CanonicalField IS 'Nasza jedna nazwa danej, niezależna od platformy.';
COMMENT ON COLUMN CanonicalField.CanonicalFieldKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN CanonicalField.CanonicalFieldName IS 'Nazwa, np. „Wynagrodzenie od”';
COMMENT ON COLUMN CanonicalField.DataSubjectKey IS 'Czego dotyczy';
COMMENT ON COLUMN CanonicalField.CanonicalFieldDescription IS 'Opis';

COMMENT ON TABLE FieldMapping IS 'Przypisanie pola platformy do naszej nazwy, z regułą przeliczenia.';
COMMENT ON COLUMN FieldMapping.FieldMappingKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN FieldMapping.EndpointDataKey IS 'Pole platformy';
COMMENT ON COLUMN FieldMapping.CanonicalFieldKey IS 'Nasza nazwa';
COMMENT ON COLUMN FieldMapping.TransformationRule IS 'Jak przeliczyć wartość, np. „grosze na złote: /100”';

ALTER TABLE HTTPMethod ADD CONSTRAINT HTTPMethod_PK PRIMARY KEY (HTTPMethodKey);
ALTER TABLE HTTPMethod ADD CONSTRAINT HTTPMethod_HTTPMethodName_UN UNIQUE (HTTPMethodName);
ALTER TABLE DataSubject ADD CONSTRAINT DataSubject_PK PRIMARY KEY (DataSubjectKey);
ALTER TABLE DataSubject ADD CONSTRAINT DataSubject_DataSubjectName_UN UNIQUE (DataSubjectName);
ALTER TABLE APIEndpoint ADD CONSTRAINT APIEndpoint_PK PRIMARY KEY (APIEndpointKey);
ALTER TABLE APIEndpoint ADD CONSTRAINT APIEndpoint_UN UNIQUE (APIVersionKey, HTTPMethodKey, EndpointPath);
ALTER TABLE APIEndpoint ADD CONSTRAINT APIEndpoint_IsPaginated_CK CHECK (IsPaginated IN ('T', 'N'));
ALTER TABLE EndpointResponse ADD CONSTRAINT EndpointResponse_PK PRIMARY KEY (EndpointResponseKey);
ALTER TABLE EndpointResponse ADD CONSTRAINT EndpointResponse_UN UNIQUE (APIEndpointKey, HTTPStatusCode, DataFormatKey);
ALTER TABLE EndpointResponse ADD CONSTRAINT EndpointResponse_IsErrorResponse_CK CHECK (IsErrorResponse IN ('T', 'N'));
ALTER TABLE EndpointResponse ADD CONSTRAINT EndpointResponse_CK1 CHECK (HTTPStatusCode BETWEEN 100 AND 599);
ALTER TABLE FieldDataType ADD CONSTRAINT FieldDataType_PK PRIMARY KEY (FieldDataTypeKey);
ALTER TABLE FieldDataType ADD CONSTRAINT FieldDataType_FieldDataTypeName_UN UNIQUE (FieldDataTypeName);
ALTER TABLE EndpointData ADD CONSTRAINT EndpointData_PK PRIMARY KEY (EndpointDataKey);
ALTER TABLE EndpointData ADD CONSTRAINT EndpointData_UN UNIQUE (EndpointResponseKey, DataPath);
ALTER TABLE EndpointData ADD CONSTRAINT EndpointData_IsRequired_CK CHECK (IsRequired IN ('T', 'N'));
ALTER TABLE CanonicalField ADD CONSTRAINT CanonicalField_PK PRIMARY KEY (CanonicalFieldKey);
ALTER TABLE CanonicalField ADD CONSTRAINT CanonicalField_CanonicalFieldName_UN UNIQUE (CanonicalFieldName);
ALTER TABLE FieldMapping ADD CONSTRAINT FieldMapping_PK PRIMARY KEY (FieldMappingKey);
ALTER TABLE FieldMapping ADD CONSTRAINT FieldMapping_UN UNIQUE (EndpointDataKey, CanonicalFieldKey);

ALTER TABLE APIEndpoint ADD CONSTRAINT APIEndpoint_HTTPMethod_FK FOREIGN KEY (HTTPMethodKey) REFERENCES HTTPMethod (HTTPMethodKey);
ALTER TABLE APIEndpoint ADD CONSTRAINT APIEndpoint_DataSubject_FK FOREIGN KEY (DataSubjectKey) REFERENCES DataSubject (DataSubjectKey);
ALTER TABLE EndpointResponse ADD CONSTRAINT EndpointResponse_APIEndpoint_FK FOREIGN KEY (APIEndpointKey) REFERENCES APIEndpoint (APIEndpointKey);
ALTER TABLE EndpointData ADD CONSTRAINT EndpointData_EndpointResponse_FK FOREIGN KEY (EndpointResponseKey) REFERENCES EndpointResponse (EndpointResponseKey);
ALTER TABLE EndpointData ADD CONSTRAINT EndpointData_EndpointData_FK FOREIGN KEY (ParentEndpointDataKey) REFERENCES EndpointData (EndpointDataKey);
ALTER TABLE EndpointData ADD CONSTRAINT EndpointData_FieldDataType_FK FOREIGN KEY (FieldDataTypeKey) REFERENCES FieldDataType (FieldDataTypeKey);
ALTER TABLE CanonicalField ADD CONSTRAINT CanonicalField_DataSubject_FK FOREIGN KEY (DataSubjectKey) REFERENCES DataSubject (DataSubjectKey);
ALTER TABLE FieldMapping ADD CONSTRAINT FieldMapping_EndpointData_FK FOREIGN KEY (EndpointDataKey) REFERENCES EndpointData (EndpointDataKey);
ALTER TABLE FieldMapping ADD CONSTRAINT FieldMapping_CanonicalField_FK FOREIGN KEY (CanonicalFieldKey) REFERENCES CanonicalField (CanonicalFieldKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (1, 'GET');
INSERT INTO HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (2, 'POST');
INSERT INTO HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (3, 'PUT');
INSERT INTO HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (4, 'PATCH');
INSERT INTO HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (5, 'DELETE');
INSERT INTO DataSubject (DataSubjectKey, DataSubjectName) VALUES (1, 'Konto firmy');
INSERT INTO DataSubject (DataSubjectKey, DataSubjectName) VALUES (2, 'Ogłoszenie');
INSERT INTO DataSubject (DataSubjectKey, DataSubjectName) VALUES (3, 'Zdarzenie ogłoszenia');
INSERT INTO DataSubject (DataSubjectKey, DataSubjectName) VALUES (4, 'Aplikacja kandydata');
INSERT INTO DataSubject (DataSubjectKey, DataSubjectName) VALUES (5, 'Status aplikacji');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (1, 'Tekst');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (2, 'Liczba całkowita');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (3, 'Liczba dziesiętna');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (4, 'Prawda / fałsz');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (5, 'Data');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (6, 'Data i godzina');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (7, 'Lista');
INSERT INTO FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (8, 'Obiekt');
INSERT INTO CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (1, 'Wynagrodzenie od', 2, 'Dolna granica widełek');
INSERT INTO CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (2, 'Rodzaj umowy', 2, NULL);
INSERT INTO CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (3, 'NIP firmy', 1, 'NIP wpisany w koncie firmy');
INSERT INTO CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (4, 'Data aplikacji', 4, NULL);
COMMIT;
