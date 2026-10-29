-- Organizm 2: API platformy
-- Jakim kanałem, w jakim formacie i z jakim zabezpieczeniem platforma przekazuje nam dane.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG02_APIType (
    APITypeKey   NUMBER(2)     NOT NULL,
    APITypeName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG02_DataFormat (
    DataFormatKey   NUMBER(2)     NOT NULL,
    DataFormatName  VARCHAR2(15)  NOT NULL,
    MimeType        VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG02_AuthMethod (
    AuthMethodKey   NUMBER(2)     NOT NULL,
    AuthMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG02_PlatformAPI (
    PlatformAPIKey     NUMBER(3)      NOT NULL,
    SourcePlatformKey  NUMBER(4)      NOT NULL,
    APITypeKey         NUMBER(2)      NOT NULL,
    DataFormatKey      NUMBER(2)      NOT NULL,
    AuthMethodKey      NUMBER(2)      NOT NULL,
    APIDirectionKey    NUMBER(2)      NOT NULL,
    PlatformAPIName    VARCHAR2(60)   NOT NULL,
    DocumentationURL   VARCHAR2(200)
);

CREATE TABLE ORG02_APIDirection (
    APIDirectionKey   NUMBER(2)     NOT NULL,
    APIDirectionName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG02_APIVersion (
    APIVersionKey   NUMBER(4)     NOT NULL,
    PlatformAPIKey  NUMBER(3)     NOT NULL,
    VersionLabel    VARCHAR2(10)  NOT NULL,
    ReleaseDate     DATE          NOT NULL,
    RetirementDate  DATE
);

CREATE TABLE ORG02_EnvironmentType (
    EnvironmentTypeKey   NUMBER(2)     NOT NULL,
    EnvironmentTypeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG02_APIEnvironment (
    APIEnvironmentKey      NUMBER(5)      NOT NULL,
    APIVersionKey          NUMBER(4)      NOT NULL,
    EnvironmentTypeKey     NUMBER(2)      NOT NULL,
    BaseURL                VARCHAR2(200)  NOT NULL,
    RequestLimitPerMinute  NUMBER(6)
);

COMMENT ON TABLE ORG02_APIType IS 'Rodzaj API – jak na schemacie z zajęć.';
COMMENT ON COLUMN ORG02_APIType.APITypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_APIType.APITypeName IS 'Nazwa rodzaju API';

COMMENT ON TABLE ORG02_DataFormat IS 'Format danych – jak na schemacie z zajęć, z typem MIME.';
COMMENT ON COLUMN ORG02_DataFormat.DataFormatKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_DataFormat.DataFormatName IS 'Nazwa formatu';
COMMENT ON COLUMN ORG02_DataFormat.MimeType IS 'Typ MIME, np. application/json';

COMMENT ON TABLE ORG02_AuthMethod IS 'Sposób uwierzytelnienia przy połączeniu z API.';
COMMENT ON COLUMN ORG02_AuthMethod.AuthMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_AuthMethod.AuthMethodName IS 'Nazwa sposobu uwierzytelnienia';

COMMENT ON TABLE ORG02_PlatformAPI IS 'Kanał wymiany danych z jedną platformą – tabela ze schematu z zajęć, rozszerzona.';
COMMENT ON COLUMN ORG02_PlatformAPI.PlatformAPIKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_PlatformAPI.SourcePlatformKey IS 'Platforma, do której należy API';
COMMENT ON COLUMN ORG02_PlatformAPI.APITypeKey IS 'Rodzaj API';
COMMENT ON COLUMN ORG02_PlatformAPI.DataFormatKey IS 'Format domyślny';
COMMENT ON COLUMN ORG02_PlatformAPI.AuthMethodKey IS 'Jak się uwierzytelniamy';
COMMENT ON COLUMN ORG02_PlatformAPI.APIDirectionKey IS 'Kto zaczyna przesyłanie danych';
COMMENT ON COLUMN ORG02_PlatformAPI.PlatformAPIName IS 'Nazwa API, np. „Partner API”';
COMMENT ON COLUMN ORG02_PlatformAPI.DocumentationURL IS 'Adres dokumentacji API';

COMMENT ON TABLE ORG02_APIDirection IS 'Kierunek przesyłania danych.';
COMMENT ON COLUMN ORG02_APIDirection.APIDirectionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_APIDirection.APIDirectionName IS 'Nazwa kierunku';

COMMENT ON TABLE ORG02_APIVersion IS 'Wersja API. Endpointy różnią się między wersjami, a stare wersje platforma wyłącza.';
COMMENT ON COLUMN ORG02_APIVersion.APIVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_APIVersion.PlatformAPIKey IS 'API, którego to wersja';
COMMENT ON COLUMN ORG02_APIVersion.VersionLabel IS 'Oznaczenie wersji, np. v2';
COMMENT ON COLUMN ORG02_APIVersion.ReleaseDate IS 'Kiedy wersja weszła';
COMMENT ON COLUMN ORG02_APIVersion.RetirementDate IS 'Kiedy platforma wyłączy tę wersję';

COMMENT ON TABLE ORG02_EnvironmentType IS 'Rodzaj środowiska API.';
COMMENT ON COLUMN ORG02_EnvironmentType.EnvironmentTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_EnvironmentType.EnvironmentTypeName IS 'Nazwa środowiska';

COMMENT ON TABLE ORG02_APIEnvironment IS 'Środowisko danej wersji API z własnym adresem i limitem zapytań.';
COMMENT ON COLUMN ORG02_APIEnvironment.APIEnvironmentKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG02_APIEnvironment.APIVersionKey IS 'Wersja API';
COMMENT ON COLUMN ORG02_APIEnvironment.EnvironmentTypeKey IS 'Rodzaj środowiska';
COMMENT ON COLUMN ORG02_APIEnvironment.BaseURL IS 'Adres bazowy, np. https://api.platforma.example/v2';
COMMENT ON COLUMN ORG02_APIEnvironment.RequestLimitPerMinute IS 'Ile zapytań na minutę pozwala platforma';

ALTER TABLE ORG02_APIType ADD CONSTRAINT ORG02_APIType_PK PRIMARY KEY (APITypeKey);
ALTER TABLE ORG02_APIType ADD CONSTRAINT ORG02_APIType_APITypeName_UN UNIQUE (APITypeName);
ALTER TABLE ORG02_DataFormat ADD CONSTRAINT ORG02_DataFormat_PK PRIMARY KEY (DataFormatKey);
ALTER TABLE ORG02_DataFormat ADD CONSTRAINT ORG02_DataFormat_DataFormatName_UN UNIQUE (DataFormatName);
ALTER TABLE ORG02_AuthMethod ADD CONSTRAINT ORG02_AuthMethod_PK PRIMARY KEY (AuthMethodKey);
ALTER TABLE ORG02_AuthMethod ADD CONSTRAINT ORG02_AuthMethod_AuthMethodName_UN UNIQUE (AuthMethodName);
ALTER TABLE ORG02_PlatformAPI ADD CONSTRAINT ORG02_PlatformAPI_PK PRIMARY KEY (PlatformAPIKey);
ALTER TABLE ORG02_APIDirection ADD CONSTRAINT ORG02_APIDirection_PK PRIMARY KEY (APIDirectionKey);
ALTER TABLE ORG02_APIDirection ADD CONSTRAINT ORG02_APIDirection_APIDirectionName_UN UNIQUE (APIDirectionName);
ALTER TABLE ORG02_APIVersion ADD CONSTRAINT ORG02_APIVersion_PK PRIMARY KEY (APIVersionKey);
ALTER TABLE ORG02_APIVersion ADD CONSTRAINT ORG02_APIVersion_UN UNIQUE (PlatformAPIKey, VersionLabel);
ALTER TABLE ORG02_EnvironmentType ADD CONSTRAINT ORG02_EnvironmentType_PK PRIMARY KEY (EnvironmentTypeKey);
ALTER TABLE ORG02_EnvironmentType ADD CONSTRAINT ORG02_EnvironmentType_EnvironmentTypeName_UN UNIQUE (EnvironmentTypeName);
ALTER TABLE ORG02_APIEnvironment ADD CONSTRAINT ORG02_APIEnvironment_PK PRIMARY KEY (APIEnvironmentKey);
ALTER TABLE ORG02_APIEnvironment ADD CONSTRAINT ORG02_APIEnvironment_UN UNIQUE (APIVersionKey, EnvironmentTypeKey);

ALTER TABLE ORG02_PlatformAPI ADD CONSTRAINT ORG02_PlatformAPI_APIType_FK FOREIGN KEY (APITypeKey) REFERENCES ORG02_APIType (APITypeKey);
ALTER TABLE ORG02_PlatformAPI ADD CONSTRAINT ORG02_PlatformAPI_DataFormat_FK FOREIGN KEY (DataFormatKey) REFERENCES ORG02_DataFormat (DataFormatKey);
ALTER TABLE ORG02_PlatformAPI ADD CONSTRAINT ORG02_PlatformAPI_AuthMethod_FK FOREIGN KEY (AuthMethodKey) REFERENCES ORG02_AuthMethod (AuthMethodKey);
ALTER TABLE ORG02_PlatformAPI ADD CONSTRAINT ORG02_PlatformAPI_APIDirection_FK FOREIGN KEY (APIDirectionKey) REFERENCES ORG02_APIDirection (APIDirectionKey);
ALTER TABLE ORG02_APIVersion ADD CONSTRAINT ORG02_APIVersion_PlatformAPI_FK FOREIGN KEY (PlatformAPIKey) REFERENCES ORG02_PlatformAPI (PlatformAPIKey);
ALTER TABLE ORG02_APIEnvironment ADD CONSTRAINT ORG02_APIEnvironment_APIVersion_FK FOREIGN KEY (APIVersionKey) REFERENCES ORG02_APIVersion (APIVersionKey);
ALTER TABLE ORG02_APIEnvironment ADD CONSTRAINT ORG02_APIEnvironment_EnvironmentType_FK FOREIGN KEY (EnvironmentTypeKey) REFERENCES ORG02_EnvironmentType (EnvironmentTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG02_APIType (APITypeKey, APITypeName) VALUES (1, 'REST');
INSERT INTO ORG02_APIType (APITypeKey, APITypeName) VALUES (2, 'GraphQL');
INSERT INTO ORG02_APIType (APITypeKey, APITypeName) VALUES (3, 'SOAP');
INSERT INTO ORG02_APIType (APITypeKey, APITypeName) VALUES (4, 'Webhook');
INSERT INTO ORG02_APIType (APITypeKey, APITypeName) VALUES (5, 'Eksport pliku');
INSERT INTO ORG02_APIType (APITypeKey, APITypeName) VALUES (6, 'Kanał RSS');
INSERT INTO ORG02_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (1, 'JSON', 'application/json');
INSERT INTO ORG02_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (2, 'XML', 'application/xml');
INSERT INTO ORG02_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (3, 'CSV', 'text/csv');
INSERT INTO ORG02_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (4, 'HTML', 'text/html');
INSERT INTO ORG02_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (1, 'Klucz API');
INSERT INTO ORG02_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (2, 'OAuth 2.0');
INSERT INTO ORG02_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (3, 'Certyfikat klienta (mTLS)');
INSERT INTO ORG02_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (4, 'Podpis HMAC');
INSERT INTO ORG02_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (5, 'Brak zabezpieczenia');
INSERT INTO ORG02_APIDirection (APIDirectionKey, APIDirectionName) VALUES (1, 'My pobieramy dane (pull)');
INSERT INTO ORG02_APIDirection (APIDirectionKey, APIDirectionName) VALUES (2, 'Platforma wysyła dane (push)');
INSERT INTO ORG02_EnvironmentType (EnvironmentTypeKey, EnvironmentTypeName) VALUES (1, 'Testowe (sandbox)');
INSERT INTO ORG02_EnvironmentType (EnvironmentTypeKey, EnvironmentTypeName) VALUES (2, 'Produkcyjne');
COMMIT;
