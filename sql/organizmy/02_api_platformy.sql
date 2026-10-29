-- Organizm 2: API platformy
-- Jakim kanałem, w jakim formacie i z jakim zabezpieczeniem platforma przekazuje nam dane.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE APIType (
    APITypeKey   NUMBER(2)     NOT NULL,
    APITypeName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE DataFormat (
    DataFormatKey   NUMBER(2)     NOT NULL,
    DataFormatName  VARCHAR2(15)  NOT NULL,
    MimeType        VARCHAR2(60)  NOT NULL
);

CREATE TABLE AuthMethod (
    AuthMethodKey   NUMBER(2)     NOT NULL,
    AuthMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE PlatformAPI (
    PlatformAPIKey     NUMBER(3)      NOT NULL,
    SourcePlatformKey  NUMBER(4)      NOT NULL,
    APITypeKey         NUMBER(2)      NOT NULL,
    DataFormatKey      NUMBER(2)      NOT NULL,
    AuthMethodKey      NUMBER(2)      NOT NULL,
    APIDirectionKey    NUMBER(2)      NOT NULL,
    PlatformAPIName    VARCHAR2(60)   NOT NULL,
    DocumentationURL   VARCHAR2(200)
);

CREATE TABLE APIDirection (
    APIDirectionKey   NUMBER(2)     NOT NULL,
    APIDirectionName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE APIVersion (
    APIVersionKey   NUMBER(4)     NOT NULL,
    PlatformAPIKey  NUMBER(3)     NOT NULL,
    VersionLabel    VARCHAR2(10)  NOT NULL,
    ReleaseDate     DATE          NOT NULL,
    RetirementDate  DATE
);

CREATE TABLE EnvironmentType (
    EnvironmentTypeKey   NUMBER(2)     NOT NULL,
    EnvironmentTypeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE APIEnvironment (
    APIEnvironmentKey      NUMBER(5)      NOT NULL,
    APIVersionKey          NUMBER(4)      NOT NULL,
    EnvironmentTypeKey     NUMBER(2)      NOT NULL,
    BaseURL                VARCHAR2(200)  NOT NULL,
    RequestLimitPerMinute  NUMBER(6)
);

COMMENT ON TABLE APIType IS 'Rodzaj API – jak na schemacie z zajęć.';
COMMENT ON COLUMN APIType.APITypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN APIType.APITypeName IS 'Nazwa rodzaju API';

COMMENT ON TABLE DataFormat IS 'Format danych – jak na schemacie z zajęć, z typem MIME.';
COMMENT ON COLUMN DataFormat.DataFormatKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN DataFormat.DataFormatName IS 'Nazwa formatu';
COMMENT ON COLUMN DataFormat.MimeType IS 'Typ MIME, np. application/json';

COMMENT ON TABLE AuthMethod IS 'Sposób uwierzytelnienia przy połączeniu z API.';
COMMENT ON COLUMN AuthMethod.AuthMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN AuthMethod.AuthMethodName IS 'Nazwa sposobu uwierzytelnienia';

COMMENT ON TABLE PlatformAPI IS 'Kanał wymiany danych z jedną platformą – tabela ze schematu z zajęć, rozszerzona.';
COMMENT ON COLUMN PlatformAPI.PlatformAPIKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PlatformAPI.SourcePlatformKey IS 'Platforma, do której należy API';
COMMENT ON COLUMN PlatformAPI.APITypeKey IS 'Rodzaj API';
COMMENT ON COLUMN PlatformAPI.DataFormatKey IS 'Format domyślny';
COMMENT ON COLUMN PlatformAPI.AuthMethodKey IS 'Jak się uwierzytelniamy';
COMMENT ON COLUMN PlatformAPI.APIDirectionKey IS 'Kto zaczyna przesyłanie danych';
COMMENT ON COLUMN PlatformAPI.PlatformAPIName IS 'Nazwa API, np. „Partner API”';
COMMENT ON COLUMN PlatformAPI.DocumentationURL IS 'Adres dokumentacji API';

COMMENT ON TABLE APIDirection IS 'Kierunek przesyłania danych.';
COMMENT ON COLUMN APIDirection.APIDirectionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN APIDirection.APIDirectionName IS 'Nazwa kierunku';

COMMENT ON TABLE APIVersion IS 'Wersja API. Endpointy różnią się między wersjami, a stare wersje platforma wyłącza.';
COMMENT ON COLUMN APIVersion.APIVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN APIVersion.PlatformAPIKey IS 'API, którego to wersja';
COMMENT ON COLUMN APIVersion.VersionLabel IS 'Oznaczenie wersji, np. v2';
COMMENT ON COLUMN APIVersion.ReleaseDate IS 'Kiedy wersja weszła';
COMMENT ON COLUMN APIVersion.RetirementDate IS 'Kiedy platforma wyłączy tę wersję';

COMMENT ON TABLE EnvironmentType IS 'Rodzaj środowiska API.';
COMMENT ON COLUMN EnvironmentType.EnvironmentTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EnvironmentType.EnvironmentTypeName IS 'Nazwa środowiska';

COMMENT ON TABLE APIEnvironment IS 'Środowisko danej wersji API z własnym adresem i limitem zapytań.';
COMMENT ON COLUMN APIEnvironment.APIEnvironmentKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN APIEnvironment.APIVersionKey IS 'Wersja API';
COMMENT ON COLUMN APIEnvironment.EnvironmentTypeKey IS 'Rodzaj środowiska';
COMMENT ON COLUMN APIEnvironment.BaseURL IS 'Adres bazowy, np. https://api.platforma.example/v2';
COMMENT ON COLUMN APIEnvironment.RequestLimitPerMinute IS 'Ile zapytań na minutę pozwala platforma';

ALTER TABLE APIType ADD CONSTRAINT APIType_PK PRIMARY KEY (APITypeKey);
ALTER TABLE APIType ADD CONSTRAINT APIType_APITypeName_UN UNIQUE (APITypeName);
ALTER TABLE DataFormat ADD CONSTRAINT DataFormat_PK PRIMARY KEY (DataFormatKey);
ALTER TABLE DataFormat ADD CONSTRAINT DataFormat_DataFormatName_UN UNIQUE (DataFormatName);
ALTER TABLE AuthMethod ADD CONSTRAINT AuthMethod_PK PRIMARY KEY (AuthMethodKey);
ALTER TABLE AuthMethod ADD CONSTRAINT AuthMethod_AuthMethodName_UN UNIQUE (AuthMethodName);
ALTER TABLE PlatformAPI ADD CONSTRAINT PlatformAPI_PK PRIMARY KEY (PlatformAPIKey);
ALTER TABLE APIDirection ADD CONSTRAINT APIDirection_PK PRIMARY KEY (APIDirectionKey);
ALTER TABLE APIDirection ADD CONSTRAINT APIDirection_APIDirectionName_UN UNIQUE (APIDirectionName);
ALTER TABLE APIVersion ADD CONSTRAINT APIVersion_PK PRIMARY KEY (APIVersionKey);
ALTER TABLE APIVersion ADD CONSTRAINT APIVersion_UN UNIQUE (PlatformAPIKey, VersionLabel);
ALTER TABLE EnvironmentType ADD CONSTRAINT EnvironmentType_PK PRIMARY KEY (EnvironmentTypeKey);
ALTER TABLE EnvironmentType ADD CONSTRAINT EnvironmentType_EnvironmentTypeName_UN UNIQUE (EnvironmentTypeName);
ALTER TABLE APIEnvironment ADD CONSTRAINT APIEnvironment_PK PRIMARY KEY (APIEnvironmentKey);
ALTER TABLE APIEnvironment ADD CONSTRAINT APIEnvironment_UN UNIQUE (APIVersionKey, EnvironmentTypeKey);

ALTER TABLE PlatformAPI ADD CONSTRAINT PlatformAPI_APIType_FK FOREIGN KEY (APITypeKey) REFERENCES APIType (APITypeKey);
ALTER TABLE PlatformAPI ADD CONSTRAINT PlatformAPI_DataFormat_FK FOREIGN KEY (DataFormatKey) REFERENCES DataFormat (DataFormatKey);
ALTER TABLE PlatformAPI ADD CONSTRAINT PlatformAPI_AuthMethod_FK FOREIGN KEY (AuthMethodKey) REFERENCES AuthMethod (AuthMethodKey);
ALTER TABLE PlatformAPI ADD CONSTRAINT PlatformAPI_APIDirection_FK FOREIGN KEY (APIDirectionKey) REFERENCES APIDirection (APIDirectionKey);
ALTER TABLE APIVersion ADD CONSTRAINT APIVersion_PlatformAPI_FK FOREIGN KEY (PlatformAPIKey) REFERENCES PlatformAPI (PlatformAPIKey);
ALTER TABLE APIEnvironment ADD CONSTRAINT APIEnvironment_APIVersion_FK FOREIGN KEY (APIVersionKey) REFERENCES APIVersion (APIVersionKey);
ALTER TABLE APIEnvironment ADD CONSTRAINT APIEnvironment_EnvironmentType_FK FOREIGN KEY (EnvironmentTypeKey) REFERENCES EnvironmentType (EnvironmentTypeKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO APIType (APITypeKey, APITypeName) VALUES (1, 'REST');
INSERT INTO APIType (APITypeKey, APITypeName) VALUES (2, 'GraphQL');
INSERT INTO APIType (APITypeKey, APITypeName) VALUES (3, 'SOAP');
INSERT INTO APIType (APITypeKey, APITypeName) VALUES (4, 'Webhook');
INSERT INTO APIType (APITypeKey, APITypeName) VALUES (5, 'Eksport pliku');
INSERT INTO APIType (APITypeKey, APITypeName) VALUES (6, 'Kanał RSS');
INSERT INTO DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (1, 'JSON', 'application/json');
INSERT INTO DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (2, 'XML', 'application/xml');
INSERT INTO DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (3, 'CSV', 'text/csv');
INSERT INTO DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (4, 'HTML', 'text/html');
INSERT INTO AuthMethod (AuthMethodKey, AuthMethodName) VALUES (1, 'Klucz API');
INSERT INTO AuthMethod (AuthMethodKey, AuthMethodName) VALUES (2, 'OAuth 2.0');
INSERT INTO AuthMethod (AuthMethodKey, AuthMethodName) VALUES (3, 'Certyfikat klienta (mTLS)');
INSERT INTO AuthMethod (AuthMethodKey, AuthMethodName) VALUES (4, 'Podpis HMAC');
INSERT INTO AuthMethod (AuthMethodKey, AuthMethodName) VALUES (5, 'Brak zabezpieczenia');
INSERT INTO APIDirection (APIDirectionKey, APIDirectionName) VALUES (1, 'My pobieramy dane (pull)');
INSERT INTO APIDirection (APIDirectionKey, APIDirectionName) VALUES (2, 'Platforma wysyła dane (push)');
INSERT INTO EnvironmentType (EnvironmentTypeKey, EnvironmentTypeName) VALUES (1, 'Testowe (sandbox)');
INSERT INTO EnvironmentType (EnvironmentTypeKey, EnvironmentTypeName) VALUES (2, 'Produkcyjne');
COMMIT;
