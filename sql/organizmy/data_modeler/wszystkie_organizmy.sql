-- Cały model naraz: wszystkie organizmy i klucze obce między nimi – do Data Modeler.

-- Organizm 1: Platforma źródłowa
-- Skąd w ogóle biorą się dane: serwis z ofertami pracy, jego adresy, kraje i umowa z nami.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG01_PlatformType (
    PlatformTypeKey   NUMBER(2)     NOT NULL,
    PlatformTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG01_SourcePlatform (
    SourcePlatformKey   NUMBER(4)      NOT NULL,
    SourcePlatformName  VARCHAR2(50)   NOT NULL,
    MainHomePage        VARCHAR2(100)  NOT NULL,
    PlatformTypeKey     NUMBER(2)      NOT NULL,
    AddedDate           DATE           NOT NULL
);

CREATE TABLE ORG01_PlatformDomain (
    PlatformDomainKey  NUMBER(5)      NOT NULL,
    SourcePlatformKey  NUMBER(4)      NOT NULL,
    DomainName         VARCHAR2(100)  NOT NULL,
    IsMainDomain       CHAR(1)        NOT NULL
);

CREATE TABLE ORG01_PlatformMarket (
    PlatformMarketKey  NUMBER(5)  NOT NULL,
    SourcePlatformKey  NUMBER(4)  NOT NULL,
    CountryKey         NUMBER(3)  NOT NULL,
    LaunchDate         DATE
);

CREATE TABLE ORG01_PartnerAgreement (
    PartnerAgreementKey         NUMBER(5)  NOT NULL,
    SourcePlatformKey           NUMBER(4)  NOT NULL,
    AgreementStatusKey          NUMBER(2)  NOT NULL,
    SignedDate                  DATE,
    ValidFrom                   DATE       NOT NULL,
    ValidTo                     DATE,
    HasDataProcessingAgreement  CHAR(1)    NOT NULL
);

CREATE TABLE ORG01_AgreementStatus (
    AgreementStatusKey   NUMBER(2)     NOT NULL,
    AgreementStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG01_Country (
    CountryKey   NUMBER(3)     NOT NULL,
    CountryCode  CHAR(2)       NOT NULL,
    CountryName  VARCHAR2(60)  NOT NULL
);

COMMENT ON TABLE ORG01_PlatformType IS 'Rodzaj platformy – odpowiedź na pytanie, czym w szerszym kontekście jest źródło ofert.';
COMMENT ON COLUMN ORG01_PlatformType.PlatformTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformType.PlatformTypeName IS 'Nazwa rodzaju platformy';

COMMENT ON TABLE ORG01_SourcePlatform IS 'Platforma, z której pochodzą dane, np. pracuj.pl albo OLX – ta sama tabela co na schemacie z zajęć.';
COMMENT ON COLUMN ORG01_SourcePlatform.SourcePlatformKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_SourcePlatform.SourcePlatformName IS 'Nazwa platformy, np. pracuj.pl';
COMMENT ON COLUMN ORG01_SourcePlatform.MainHomePage IS 'Adres strony głównej';
COMMENT ON COLUMN ORG01_SourcePlatform.PlatformTypeKey IS 'Rodzaj platformy';
COMMENT ON COLUMN ORG01_SourcePlatform.AddedDate IS 'Kiedy dodaliśmy platformę jako źródło';

COMMENT ON TABLE ORG01_PlatformDomain IS 'Adres, pod którym działa platforma. Jedna platforma ma ich kilka.';
COMMENT ON COLUMN ORG01_PlatformDomain.PlatformDomainKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformDomain.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PlatformDomain.DomainName IS 'Domena, np. it.pracuj.pl';
COMMENT ON COLUMN ORG01_PlatformDomain.IsMainDomain IS 'Czy to główny adres platformy';

COMMENT ON TABLE ORG01_PlatformMarket IS 'Kraj, w którym platforma publikuje oferty – tabela łącząca platformy z krajami.';
COMMENT ON COLUMN ORG01_PlatformMarket.PlatformMarketKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformMarket.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PlatformMarket.CountryKey IS 'Kraj';
COMMENT ON COLUMN ORG01_PlatformMarket.LaunchDate IS 'Od kiedy platforma działa w tym kraju';

COMMENT ON TABLE ORG01_PartnerAgreement IS 'Umowa o współpracy z platformą. Każda zmiana warunków to nowy wiersz, więc widać całą historię współpracy.';
COMMENT ON COLUMN ORG01_PartnerAgreement.PartnerAgreementKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PartnerAgreement.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PartnerAgreement.AgreementStatusKey IS 'Etap umowy';
COMMENT ON COLUMN ORG01_PartnerAgreement.SignedDate IS 'Data podpisania';
COMMENT ON COLUMN ORG01_PartnerAgreement.ValidFrom IS 'Od kiedy obowiązuje';
COMMENT ON COLUMN ORG01_PartnerAgreement.ValidTo IS 'Do kiedy obowiązuje (puste = bez końca)';
COMMENT ON COLUMN ORG01_PartnerAgreement.HasDataProcessingAgreement IS 'Czy podpisano umowę powierzenia danych osobowych (RODO)';

COMMENT ON TABLE ORG01_AgreementStatus IS 'Etap umowy z platformą.';
COMMENT ON COLUMN ORG01_AgreementStatus.AgreementStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_AgreementStatus.AgreementStatusName IS 'Nazwa etapu umowy';

COMMENT ON TABLE ORG01_Country IS 'Kraj – słownik używany też w organizmach 6 i 8.';
COMMENT ON COLUMN ORG01_Country.CountryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_Country.CountryCode IS 'Kod kraju ISO, np. PL';
COMMENT ON COLUMN ORG01_Country.CountryName IS 'Nazwa kraju';

ALTER TABLE ORG01_PlatformType ADD CONSTRAINT ORG01_PlatformType_PK PRIMARY KEY (PlatformTypeKey);
ALTER TABLE ORG01_PlatformType ADD CONSTRAINT ORG01_PlatformType_PlatformTypeName_UN UNIQUE (PlatformTypeName);
ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_PK PRIMARY KEY (SourcePlatformKey);
ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_SourcePlatformName_UN UNIQUE (SourcePlatformName);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_PK PRIMARY KEY (PlatformDomainKey);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_DomainName_UN UNIQUE (DomainName);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_IsMainDomain_CK CHECK (IsMainDomain IN ('T', 'N'));
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_PK PRIMARY KEY (PlatformMarketKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_UN UNIQUE (SourcePlatformKey, CountryKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_PK PRIMARY KEY (PartnerAgreementKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_HasDataProcessingAgreement_CK CHECK (HasDataProcessingAgreement IN ('T', 'N'));
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG01_AgreementStatus ADD CONSTRAINT ORG01_AgreementStatus_PK PRIMARY KEY (AgreementStatusKey);
ALTER TABLE ORG01_AgreementStatus ADD CONSTRAINT ORG01_AgreementStatus_AgreementStatusName_UN UNIQUE (AgreementStatusName);
ALTER TABLE ORG01_Country ADD CONSTRAINT ORG01_Country_PK PRIMARY KEY (CountryKey);
ALTER TABLE ORG01_Country ADD CONSTRAINT ORG01_Country_CountryCode_UN UNIQUE (CountryCode);

ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_PlatformType_FK FOREIGN KEY (PlatformTypeKey) REFERENCES ORG01_PlatformType (PlatformTypeKey);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_AgreementStatus_FK FOREIGN KEY (AgreementStatusKey) REFERENCES ORG01_AgreementStatus (AgreementStatusKey);

-- Organizm 2: API platformy
-- Jakim kanałem, w jakim formacie i z jakim zabezpieczeniem platforma przekazuje nam dane.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
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
ALTER TABLE ORG02_APIVersion ADD CONSTRAINT ORG02_APIVersion_CK1 CHECK (RetirementDate IS NULL OR RetirementDate >= ReleaseDate);
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

-- Organizm 3: Endpointy i zwracane dane
-- Jakie konkretne zapytania ma API i jakie pola zwraca każde z nich.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
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

-- Organizm 4: Odbiór danych z platformy
-- Każda dostawa danych: kiedy, którym endpointem, z jakim skutkiem – i surowa kopia każdego rekordu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG04_DeliveryMode (
    DeliveryModeKey   NUMBER(2)     NOT NULL,
    DeliveryModeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG04_DeliveryStatus (
    DeliveryStatusKey   NUMBER(2)     NOT NULL,
    DeliveryStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG04_DataDelivery (
    DataDeliveryKey    NUMBER(10)  NOT NULL,
    APIEndpointKey     NUMBER(6)   NOT NULL,
    DeliveryModeKey    NUMBER(2)   NOT NULL,
    DeliveryStatusKey  NUMBER(2)   NOT NULL,
    StartedAt          TIMESTAMP   NOT NULL,
    FinishedAt         TIMESTAMP,
    RecordsReceived    NUMBER(7),
    RecordsAccepted    NUMBER(7)
);

CREATE TABLE ORG04_RawRecord (
    RawRecordKey      NUMBER(12)     NOT NULL,
    DataDeliveryKey   NUMBER(10)     NOT NULL,
    ExternalRecordId  VARCHAR2(100)  NOT NULL,
    RecordPayload     CLOB           NOT NULL,
    PayloadHash       VARCHAR2(64)   NOT NULL,
    ReceivedAt        TIMESTAMP      NOT NULL
);

CREATE TABLE ORG04_DeliveryError (
    DeliveryErrorKey  NUMBER(10)     NOT NULL,
    DataDeliveryKey   NUMBER(10)     NOT NULL,
    RawRecordKey      NUMBER(12),
    ErrorTypeKey      NUMBER(2)      NOT NULL,
    ErrorMessage      VARCHAR2(400),
    OccurredAt        TIMESTAMP      NOT NULL
);

CREATE TABLE ORG04_ErrorType (
    ErrorTypeKey   NUMBER(2)     NOT NULL,
    ErrorTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG04_DeliveryMode IS 'Sposób, w jaki dane do nas trafiły.';
COMMENT ON COLUMN ORG04_DeliveryMode.DeliveryModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DeliveryMode.DeliveryModeName IS 'Nazwa sposobu dostawy';

COMMENT ON TABLE ORG04_DeliveryStatus IS 'Wynik dostawy.';
COMMENT ON COLUMN ORG04_DeliveryStatus.DeliveryStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DeliveryStatus.DeliveryStatusName IS 'Nazwa wyniku';

COMMENT ON TABLE ORG04_DataDelivery IS 'Jedna dostawa danych jednym endpointem.';
COMMENT ON COLUMN ORG04_DataDelivery.DataDeliveryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DataDelivery.APIEndpointKey IS 'Którym endpointem przyszły dane';
COMMENT ON COLUMN ORG04_DataDelivery.DeliveryModeKey IS 'Sposób dostawy';
COMMENT ON COLUMN ORG04_DataDelivery.DeliveryStatusKey IS 'Wynik dostawy';
COMMENT ON COLUMN ORG04_DataDelivery.StartedAt IS 'Początek';
COMMENT ON COLUMN ORG04_DataDelivery.FinishedAt IS 'Koniec';
COMMENT ON COLUMN ORG04_DataDelivery.RecordsReceived IS 'Ile rekordów przyszło';
COMMENT ON COLUMN ORG04_DataDelivery.RecordsAccepted IS 'Ile rekordów przyjęliśmy';

COMMENT ON TABLE ORG04_RawRecord IS 'Rekord dokładnie w takiej postaci, w jakiej przyszedł od platformy.';
COMMENT ON COLUMN ORG04_RawRecord.RawRecordKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_RawRecord.DataDeliveryKey IS 'Dostawa';
COMMENT ON COLUMN ORG04_RawRecord.ExternalRecordId IS 'Numer rekordu u platformy';
COMMENT ON COLUMN ORG04_RawRecord.RecordPayload IS 'Treść rekordu bez zmian (np. JSON)';
COMMENT ON COLUMN ORG04_RawRecord.PayloadHash IS 'Skrót SHA-256 treści – do wykrywania duplikatów';
COMMENT ON COLUMN ORG04_RawRecord.ReceivedAt IS 'Kiedy rekord przyszedł';

COMMENT ON TABLE ORG04_DeliveryError IS 'Błąd dostawy albo pojedynczego rekordu.';
COMMENT ON COLUMN ORG04_DeliveryError.DeliveryErrorKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_DeliveryError.DataDeliveryKey IS 'Dostawa';
COMMENT ON COLUMN ORG04_DeliveryError.RawRecordKey IS 'Którego rekordu dotyczy (puste = całej dostawy)';
COMMENT ON COLUMN ORG04_DeliveryError.ErrorTypeKey IS 'Rodzaj błędu';
COMMENT ON COLUMN ORG04_DeliveryError.ErrorMessage IS 'Treść błędu';
COMMENT ON COLUMN ORG04_DeliveryError.OccurredAt IS 'Kiedy wystąpił';

COMMENT ON TABLE ORG04_ErrorType IS 'Rodzaj błędu przy odbiorze danych.';
COMMENT ON COLUMN ORG04_ErrorType.ErrorTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG04_ErrorType.ErrorTypeName IS 'Nazwa rodzaju błędu';

ALTER TABLE ORG04_DeliveryMode ADD CONSTRAINT ORG04_DeliveryMode_PK PRIMARY KEY (DeliveryModeKey);
ALTER TABLE ORG04_DeliveryMode ADD CONSTRAINT ORG04_DeliveryMode_DeliveryModeName_UN UNIQUE (DeliveryModeName);
ALTER TABLE ORG04_DeliveryStatus ADD CONSTRAINT ORG04_DeliveryStatus_PK PRIMARY KEY (DeliveryStatusKey);
ALTER TABLE ORG04_DeliveryStatus ADD CONSTRAINT ORG04_DeliveryStatus_DeliveryStatusName_UN UNIQUE (DeliveryStatusName);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_PK PRIMARY KEY (DataDeliveryKey);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_CK1 CHECK (RecordsAccepted <= RecordsReceived);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_CK2 CHECK (FinishedAt IS NULL OR FinishedAt >= StartedAt);
ALTER TABLE ORG04_RawRecord ADD CONSTRAINT ORG04_RawRecord_PK PRIMARY KEY (RawRecordKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_PK PRIMARY KEY (DeliveryErrorKey);
ALTER TABLE ORG04_ErrorType ADD CONSTRAINT ORG04_ErrorType_PK PRIMARY KEY (ErrorTypeKey);
ALTER TABLE ORG04_ErrorType ADD CONSTRAINT ORG04_ErrorType_ErrorTypeName_UN UNIQUE (ErrorTypeName);

ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_DeliveryMode_FK FOREIGN KEY (DeliveryModeKey) REFERENCES ORG04_DeliveryMode (DeliveryModeKey);
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_DeliveryStatus_FK FOREIGN KEY (DeliveryStatusKey) REFERENCES ORG04_DeliveryStatus (DeliveryStatusKey);
ALTER TABLE ORG04_RawRecord ADD CONSTRAINT ORG04_RawRecord_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES ORG04_RawRecord (RawRecordKey);
ALTER TABLE ORG04_DeliveryError ADD CONSTRAINT ORG04_DeliveryError_ErrorType_FK FOREIGN KEY (ErrorTypeKey) REFERENCES ORG04_ErrorType (ErrorTypeKey);

-- Organizm 5: Konto firmy na platformie
-- Profil, pod którym ktoś publikuje ogłoszenia – zanim wiemy, jaka firma za nim stoi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG05_AccountType (
    AccountTypeKey   NUMBER(2)     NOT NULL,
    AccountTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG05_AccountStatus (
    AccountStatusKey   NUMBER(2)     NOT NULL,
    AccountStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG05_EmployerAccount (
    EmployerAccountKey    NUMBER(8)     NOT NULL,
    SourcePlatformKey     NUMBER(4)     NOT NULL,
    ExternalAccountId     VARCHAR2(50)  NOT NULL,
    AccountTypeKey        NUMBER(2)     NOT NULL,
    AccountStatusKey      NUMBER(2)     NOT NULL,
    IsVerifiedByPlatform  CHAR(1)       NOT NULL,
    FirstSeenAt           TIMESTAMP     NOT NULL
);

CREATE TABLE ORG05_EmployerAccountVersion (
    EmployerAccountVersionKey  NUMBER(9)      NOT NULL,
    EmployerAccountKey         NUMBER(8)      NOT NULL,
    AccountName                VARCHAR2(200)  NOT NULL,
    DeclaredNIP                VARCHAR2(10),
    WebsiteURL                 VARCHAR2(200),
    ValidFrom                  TIMESTAMP      NOT NULL,
    ValidTo                    TIMESTAMP,
    RawRecordKey               NUMBER(12)
);

COMMENT ON TABLE ORG05_AccountType IS 'Kto prowadzi konto.';
COMMENT ON COLUMN ORG05_AccountType.AccountTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_AccountType.AccountTypeName IS 'Nazwa rodzaju konta';

COMMENT ON TABLE ORG05_AccountStatus IS 'Stan konta na platformie.';
COMMENT ON COLUMN ORG05_AccountStatus.AccountStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_AccountStatus.AccountStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG05_EmployerAccount IS 'Konto na jednej platformie.';
COMMENT ON COLUMN ORG05_EmployerAccount.EmployerAccountKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_EmployerAccount.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG05_EmployerAccount.ExternalAccountId IS 'Numer konta w serwisie';
COMMENT ON COLUMN ORG05_EmployerAccount.AccountTypeKey IS 'Kto prowadzi konto';
COMMENT ON COLUMN ORG05_EmployerAccount.AccountStatusKey IS 'Stan konta';
COMMENT ON COLUMN ORG05_EmployerAccount.IsVerifiedByPlatform IS 'Czy platforma sama sprawdziła firmę';
COMMENT ON COLUMN ORG05_EmployerAccount.FirstSeenAt IS 'Kiedy pierwszy raz dostaliśmy to konto';

COMMENT ON TABLE ORG05_EmployerAccountVersion IS 'Wersja danych konta – każda zmiana to nowy wiersz.';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.EmployerAccountVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.AccountName IS 'Nazwa konta';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.DeclaredNIP IS 'NIP wpisany przez właściciela konta (niesprawdzony)';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.WebsiteURL IS 'Strona www podana w koncie';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.ValidFrom IS 'Od kiedy dane są takie';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.ValidTo IS 'Do kiedy (puste = wersja aktualna)';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.RawRecordKey IS 'Rekord, z którego pochodzi ta wersja';

ALTER TABLE ORG05_AccountType ADD CONSTRAINT ORG05_AccountType_PK PRIMARY KEY (AccountTypeKey);
ALTER TABLE ORG05_AccountType ADD CONSTRAINT ORG05_AccountType_AccountTypeName_UN UNIQUE (AccountTypeName);
ALTER TABLE ORG05_AccountStatus ADD CONSTRAINT ORG05_AccountStatus_PK PRIMARY KEY (AccountStatusKey);
ALTER TABLE ORG05_AccountStatus ADD CONSTRAINT ORG05_AccountStatus_AccountStatusName_UN UNIQUE (AccountStatusName);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_PK PRIMARY KEY (EmployerAccountKey);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_UN UNIQUE (SourcePlatformKey, ExternalAccountId);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_IsVerifiedByPlatform_CK CHECK (IsVerifiedByPlatform IN ('T', 'N'));
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_PK PRIMARY KEY (EmployerAccountVersionKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo > ValidFrom);

ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_AccountType_FK FOREIGN KEY (AccountTypeKey) REFERENCES ORG05_AccountType (AccountTypeKey);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_AccountStatus_FK FOREIGN KEY (AccountStatusKey) REFERENCES ORG05_AccountStatus (AccountStatusKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);

-- Organizm 6: Firma w rejestrach publicznych
-- Podmiot prawny stojący za ogłoszeniami, sprawdzony w rejestrach państwowych.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG06_LegalForm (
    LegalFormKey        NUMBER(2)     NOT NULL,
    LegalFormName       VARCHAR2(60)  NOT NULL,
    LegalFormShortName  VARCHAR2(20)
);

CREATE TABLE ORG06_PKDCode (
    PKDCodeKey             NUMBER(4)      NOT NULL,
    PKDSymbol              VARCHAR2(7)    NOT NULL,
    PKDName                VARCHAR2(250)  NOT NULL,
    ClassificationVersion  VARCHAR2(10)   NOT NULL
);

CREATE TABLE ORG06_EmployerIdentifier (
    EmployerIdentifierKey  NUMBER(9)     NOT NULL,
    EmployerKey            NUMBER(8)     NOT NULL,
    IdentifierTypeKey      NUMBER(2)     NOT NULL,
    IdentifierValue        VARCHAR2(30)  NOT NULL,
    IsChecksumValid        CHAR(1)       NOT NULL
);

CREATE TABLE ORG06_Employer (
    EmployerKey        NUMBER(8)      NOT NULL,
    OfficialName       VARCHAR2(250)  NOT NULL,
    LegalFormKey       NUMBER(2)      NOT NULL,
    CountryKey         NUMBER(3)      NOT NULL,
    EmployerStatusKey  NUMBER(2)      NOT NULL,
    RegistrationDate   DATE
);

CREATE TABLE ORG06_EmployerPKD (
    EmployerPKDKey  NUMBER(9)  NOT NULL,
    EmployerKey     NUMBER(8)  NOT NULL,
    PKDCodeKey      NUMBER(4)  NOT NULL,
    IsMainActivity  CHAR(1)    NOT NULL
);

CREATE TABLE ORG06_IdentifierType (
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    IdentifierTypeName  VARCHAR2(40)  NOT NULL,
    ValueFormat         VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG06_RegistryCheck (
    RegistryCheckKey   NUMBER(10)     NOT NULL,
    EmployerKey        NUMBER(8)      NOT NULL,
    PublicRegistryKey  NUMBER(2)      NOT NULL,
    CheckedAt          TIMESTAMP      NOT NULL,
    WasFound           CHAR(1)        NOT NULL,
    ReportedStatusKey  NUMBER(2),
    ReportedName       VARCHAR2(250)
);

CREATE TABLE ORG06_EmployerStatus (
    EmployerStatusKey   NUMBER(2)     NOT NULL,
    EmployerStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG06_PublicRegistry (
    PublicRegistryKey   NUMBER(2)     NOT NULL,
    PublicRegistryName  VARCHAR2(60)  NOT NULL,
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    DailyQueryLimit     NUMBER(7)
);

COMMENT ON TABLE ORG06_LegalForm IS 'Forma prawna podmiotu.';
COMMENT ON COLUMN ORG06_LegalForm.LegalFormKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_LegalForm.LegalFormName IS 'Pełna nazwa formy prawnej';
COMMENT ON COLUMN ORG06_LegalForm.LegalFormShortName IS 'Skrót, np. sp. z o.o.';

COMMENT ON TABLE ORG06_PKDCode IS 'Rodzaj działalności z klasyfikacji PKD.';
COMMENT ON COLUMN ORG06_PKDCode.PKDCodeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PKDCode.PKDSymbol IS 'Symbol, np. 78.10.Z';
COMMENT ON COLUMN ORG06_PKDCode.PKDName IS 'Nazwa działalności';
COMMENT ON COLUMN ORG06_PKDCode.ClassificationVersion IS 'Wersja klasyfikacji, np. PKD 2007 albo PKD 2025';

COMMENT ON TABLE ORG06_EmployerIdentifier IS 'Numer identyfikacyjny firmy – NIP, REGON, KRS albo numer zagraniczny.';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerIdentifierKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierTypeKey IS 'Rodzaj numeru';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierValue IS 'Numer';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IsChecksumValid IS 'Czy numer przeszedł kontrolę sumy kontrolnej';

COMMENT ON TABLE ORG06_Employer IS 'Podmiot prawny – jeden wiersz to jedna prawdziwa firma. Dla niego liczymy Trust Score.';
COMMENT ON COLUMN ORG06_Employer.EmployerKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_Employer.OfficialName IS 'Nazwa urzędowa';
COMMENT ON COLUMN ORG06_Employer.LegalFormKey IS 'Forma prawna';
COMMENT ON COLUMN ORG06_Employer.CountryKey IS 'Kraj rejestracji';
COMMENT ON COLUMN ORG06_Employer.EmployerStatusKey IS 'Aktualny status';
COMMENT ON COLUMN ORG06_Employer.RegistrationDate IS 'Data wpisu do rejestru';

COMMENT ON TABLE ORG06_EmployerPKD IS 'Rodzaj działalności firmy – tabela łącząca firmy z kodami PKD.';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerPKDKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerPKD.PKDCodeKey IS 'Kod PKD';
COMMENT ON COLUMN ORG06_EmployerPKD.IsMainActivity IS 'Czy to działalność główna';

COMMENT ON TABLE ORG06_IdentifierType IS 'Rodzaj numeru identyfikacyjnego.';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeName IS 'Nazwa rodzaju numeru';
COMMENT ON COLUMN ORG06_IdentifierType.ValueFormat IS 'Jak wygląda poprawny numer';

COMMENT ON TABLE ORG06_RegistryCheck IS 'Jedno sprawdzenie firmy w jednym rejestrze. Nowe sprawdzenie to nowy wiersz.';
COMMENT ON COLUMN ORG06_RegistryCheck.RegistryCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_RegistryCheck.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_RegistryCheck.PublicRegistryKey IS 'Rejestr';
COMMENT ON COLUMN ORG06_RegistryCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN ORG06_RegistryCheck.WasFound IS 'Czy rejestr znalazł firmę';
COMMENT ON COLUMN ORG06_RegistryCheck.ReportedStatusKey IS 'Status podany przez rejestr';
COMMENT ON COLUMN ORG06_RegistryCheck.ReportedName IS 'Nazwa podana przez rejestr';

COMMENT ON TABLE ORG06_EmployerStatus IS 'Status firmy w rejestrze.';
COMMENT ON COLUMN ORG06_EmployerStatus.EmployerStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerStatus.EmployerStatusName IS 'Nazwa statusu';

COMMENT ON TABLE ORG06_PublicRegistry IS 'Rejestr państwowy, w którym sprawdzamy firmy.';
COMMENT ON COLUMN ORG06_PublicRegistry.PublicRegistryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PublicRegistry.PublicRegistryName IS 'Nazwa rejestru';
COMMENT ON COLUMN ORG06_PublicRegistry.IdentifierTypeKey IS 'Po jakim numerze pytamy rejestr';
COMMENT ON COLUMN ORG06_PublicRegistry.DailyQueryLimit IS 'Ile zapytań dziennie pozwala rejestr';

ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_PK PRIMARY KEY (LegalFormKey);
ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_LegalFormName_UN UNIQUE (LegalFormName);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_PK PRIMARY KEY (PKDCodeKey);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_UN UNIQUE (PKDSymbol, ClassificationVersion);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_PK PRIMARY KEY (EmployerIdentifierKey);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_UN UNIQUE (IdentifierTypeKey, IdentifierValue);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_IsChecksumValid_CK CHECK (IsChecksumValid IN ('T', 'N'));
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_PK PRIMARY KEY (EmployerKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_PK PRIMARY KEY (EmployerPKDKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_UN UNIQUE (EmployerKey, PKDCodeKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_IsMainActivity_CK CHECK (IsMainActivity IN ('T', 'N'));
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_PK PRIMARY KEY (IdentifierTypeKey);
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_IdentifierTypeName_UN UNIQUE (IdentifierTypeName);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_PK PRIMARY KEY (RegistryCheckKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_WasFound_CK CHECK (WasFound IN ('T', 'N'));
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_PK PRIMARY KEY (EmployerStatusKey);
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_EmployerStatusName_UN UNIQUE (EmployerStatusName);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PK PRIMARY KEY (PublicRegistryKey);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PublicRegistryName_UN UNIQUE (PublicRegistryName);

ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_IdentifierType_FK FOREIGN KEY (IdentifierTypeKey) REFERENCES ORG06_IdentifierType (IdentifierTypeKey);
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_LegalForm_FK FOREIGN KEY (LegalFormKey) REFERENCES ORG06_LegalForm (LegalFormKey);
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_EmployerStatus_FK FOREIGN KEY (EmployerStatusKey) REFERENCES ORG06_EmployerStatus (EmployerStatusKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_PKDCode_FK FOREIGN KEY (PKDCodeKey) REFERENCES ORG06_PKDCode (PKDCodeKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_PublicRegistry_FK FOREIGN KEY (PublicRegistryKey) REFERENCES ORG06_PublicRegistry (PublicRegistryKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_EmployerStatus_FK FOREIGN KEY (ReportedStatusKey) REFERENCES ORG06_EmployerStatus (EmployerStatusKey);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_IdentifierType_FK FOREIGN KEY (IdentifierTypeKey) REFERENCES ORG06_IdentifierType (IdentifierTypeKey);

-- Organizm 7: Powiązanie kont z firmą
-- Które konta z różnych platform należą do tej samej firmy – z dowodami i historią zmian.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG07_MatchMethod (
    MatchMethodKey   NUMBER(2)     NOT NULL,
    MatchMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG07_LinkEvidence (
    LinkEvidenceKey         NUMBER(10)     NOT NULL,
    AccountEmployerLinkKey  NUMBER(9)      NOT NULL,
    EvidenceTypeKey         NUMBER(2)      NOT NULL,
    EvidenceValue           VARCHAR2(250)  NOT NULL
);

CREATE TABLE ORG07_AccountEmployerLink (
    AccountEmployerLinkKey  NUMBER(9)    NOT NULL,
    EmployerAccountKey      NUMBER(8)    NOT NULL,
    EmployerKey             NUMBER(8)    NOT NULL,
    MatchMethodKey          NUMBER(2)    NOT NULL,
    MatchConfidence         NUMBER(3,2)  NOT NULL,
    LinkedAt                TIMESTAMP    NOT NULL,
    UnlinkedAt              TIMESTAMP
);

CREATE TABLE ORG07_AgencyClient (
    AgencyClientKey    NUMBER(8)  NOT NULL,
    AgencyEmployerKey  NUMBER(8)  NOT NULL,
    ClientEmployerKey  NUMBER(8)  NOT NULL,
    ValidFrom          DATE       NOT NULL,
    ValidTo            DATE
);

CREATE TABLE ORG07_EvidenceType (
    EvidenceTypeKey   NUMBER(2)     NOT NULL,
    EvidenceTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG07_LinkChange (
    LinkChangeKey           NUMBER(10)     NOT NULL,
    AccountEmployerLinkKey  NUMBER(9)      NOT NULL,
    LinkChangeTypeKey       NUMBER(2)      NOT NULL,
    ChangedAt               TIMESTAMP      NOT NULL,
    ChangeReason            VARCHAR2(300)
);

CREATE TABLE ORG07_LinkChangeType (
    LinkChangeTypeKey   NUMBER(2)     NOT NULL,
    LinkChangeTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG07_MatchMethod IS 'Sposób, w jaki dopasowaliśmy konto do firmy.';
COMMENT ON COLUMN ORG07_MatchMethod.MatchMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_MatchMethod.MatchMethodName IS 'Nazwa sposobu dopasowania';

COMMENT ON TABLE ORG07_LinkEvidence IS 'Dowód, na którym opiera się powiązanie.';
COMMENT ON COLUMN ORG07_LinkEvidence.LinkEvidenceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkEvidence.AccountEmployerLinkKey IS 'Powiązanie';
COMMENT ON COLUMN ORG07_LinkEvidence.EvidenceTypeKey IS 'Rodzaj dowodu';
COMMENT ON COLUMN ORG07_LinkEvidence.EvidenceValue IS 'Treść dowodu, np. „ten sam NIP w koncie i w KRS”';

COMMENT ON TABLE ORG07_AccountEmployerLink IS 'Powiązanie konta na platformie z firmą z rejestru.';
COMMENT ON COLUMN ORG07_AccountEmployerLink.AccountEmployerLinkKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_AccountEmployerLink.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN ORG07_AccountEmployerLink.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG07_AccountEmployerLink.MatchMethodKey IS 'Sposób dopasowania';
COMMENT ON COLUMN ORG07_AccountEmployerLink.MatchConfidence IS 'Pewność od 0 do 1';
COMMENT ON COLUMN ORG07_AccountEmployerLink.LinkedAt IS 'Kiedy połączono';
COMMENT ON COLUMN ORG07_AccountEmployerLink.UnlinkedAt IS 'Kiedy cofnięto (puste = obowiązuje)';

COMMENT ON TABLE ORG07_AgencyClient IS 'Agencja rekrutacyjna i firma, dla której rekrutuje – dwa klucze do tej samej tabeli.';
COMMENT ON COLUMN ORG07_AgencyClient.AgencyClientKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_AgencyClient.AgencyEmployerKey IS 'Agencja rekrutacyjna';
COMMENT ON COLUMN ORG07_AgencyClient.ClientEmployerKey IS 'Firma, dla której agencja rekrutuje';
COMMENT ON COLUMN ORG07_AgencyClient.ValidFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG07_AgencyClient.ValidTo IS 'Do kiedy (puste = nadal)';

COMMENT ON TABLE ORG07_EvidenceType IS 'Rodzaj dowodu powiązania.';
COMMENT ON COLUMN ORG07_EvidenceType.EvidenceTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_EvidenceType.EvidenceTypeName IS 'Nazwa rodzaju dowodu';

COMMENT ON TABLE ORG07_LinkChange IS 'Zmiana powiązania – historia połączeń i rozłączeń.';
COMMENT ON COLUMN ORG07_LinkChange.LinkChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkChange.AccountEmployerLinkKey IS 'Powiązanie';
COMMENT ON COLUMN ORG07_LinkChange.LinkChangeTypeKey IS 'Co zmieniono';
COMMENT ON COLUMN ORG07_LinkChange.ChangedAt IS 'Kiedy';
COMMENT ON COLUMN ORG07_LinkChange.ChangeReason IS 'Dlaczego';

COMMENT ON TABLE ORG07_LinkChangeType IS 'Rodzaj zmiany powiązania.';
COMMENT ON COLUMN ORG07_LinkChangeType.LinkChangeTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkChangeType.LinkChangeTypeName IS 'Nazwa rodzaju zmiany';

ALTER TABLE ORG07_MatchMethod ADD CONSTRAINT ORG07_MatchMethod_PK PRIMARY KEY (MatchMethodKey);
ALTER TABLE ORG07_MatchMethod ADD CONSTRAINT ORG07_MatchMethod_MatchMethodName_UN UNIQUE (MatchMethodName);
ALTER TABLE ORG07_LinkEvidence ADD CONSTRAINT ORG07_LinkEvidence_PK PRIMARY KEY (LinkEvidenceKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_PK PRIMARY KEY (AccountEmployerLinkKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_CK1 CHECK (MatchConfidence BETWEEN 0 AND 1);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_CK2 CHECK (UnlinkedAt IS NULL OR UnlinkedAt >= LinkedAt);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_PK PRIMARY KEY (AgencyClientKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_UN UNIQUE (AgencyEmployerKey, ClientEmployerKey, ValidFrom);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_CK1 CHECK (AgencyEmployerKey <> ClientEmployerKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_CK2 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG07_EvidenceType ADD CONSTRAINT ORG07_EvidenceType_PK PRIMARY KEY (EvidenceTypeKey);
ALTER TABLE ORG07_EvidenceType ADD CONSTRAINT ORG07_EvidenceType_EvidenceTypeName_UN UNIQUE (EvidenceTypeName);
ALTER TABLE ORG07_LinkChange ADD CONSTRAINT ORG07_LinkChange_PK PRIMARY KEY (LinkChangeKey);
ALTER TABLE ORG07_LinkChangeType ADD CONSTRAINT ORG07_LinkChangeType_PK PRIMARY KEY (LinkChangeTypeKey);
ALTER TABLE ORG07_LinkChangeType ADD CONSTRAINT ORG07_LinkChangeType_LinkChangeTypeName_UN UNIQUE (LinkChangeTypeName);

ALTER TABLE ORG07_LinkEvidence ADD CONSTRAINT ORG07_LinkEvidence_AccountEmployerLink_FK FOREIGN KEY (AccountEmployerLinkKey) REFERENCES ORG07_AccountEmployerLink (AccountEmployerLinkKey);
ALTER TABLE ORG07_LinkEvidence ADD CONSTRAINT ORG07_LinkEvidence_EvidenceType_FK FOREIGN KEY (EvidenceTypeKey) REFERENCES ORG07_EvidenceType (EvidenceTypeKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_MatchMethod_FK FOREIGN KEY (MatchMethodKey) REFERENCES ORG07_MatchMethod (MatchMethodKey);
ALTER TABLE ORG07_LinkChange ADD CONSTRAINT ORG07_LinkChange_AccountEmployerLink_FK FOREIGN KEY (AccountEmployerLinkKey) REFERENCES ORG07_AccountEmployerLink (AccountEmployerLinkKey);
ALTER TABLE ORG07_LinkChange ADD CONSTRAINT ORG07_LinkChange_LinkChangeType_FK FOREIGN KEY (LinkChangeTypeKey) REFERENCES ORG07_LinkChangeType (LinkChangeTypeKey);

-- Organizm 8: Ogłoszenie i miejsce pracy
-- Samo ogłoszenie: kto je opublikował, kiedy, na jakim poziomie, w jakim trybie i w których miastach.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG08_PostingStatus (
    PostingStatusKey   NUMBER(2)     NOT NULL,
    PostingStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG08_SeniorityLevel (
    SeniorityLevelKey   NUMBER(2)     NOT NULL,
    SeniorityLevelName  VARCHAR2(40)  NOT NULL,
    SeniorityRank       NUMBER(2)     NOT NULL
);

CREATE TABLE ORG08_JobPosting (
    JobPostingKey       NUMBER(10)     NOT NULL,
    EmployerAccountKey  NUMBER(8)      NOT NULL,
    ExternalPostingId   VARCHAR2(50)   NOT NULL,
    PostingTitle        VARCHAR2(200)  NOT NULL,
    PostingStatusKey    NUMBER(2)      NOT NULL,
    SeniorityLevelKey   NUMBER(2),
    WorkModeKey         NUMBER(2),
    VacancyCount        NUMBER(3),
    PublishedDate       DATE           NOT NULL,
    ExpiryDate          DATE,
    RawRecordKey        NUMBER(12)
);

CREATE TABLE ORG08_WorkMode (
    WorkModeKey   NUMBER(2)     NOT NULL,
    WorkModeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG08_PostingLocation (
    PostingLocationKey  NUMBER(11)  NOT NULL,
    JobPostingKey       NUMBER(10)  NOT NULL,
    LocationKey         NUMBER(6)   NOT NULL,
    IsMainLocation      CHAR(1)     NOT NULL
);

CREATE TABLE ORG08_Location (
    LocationKey  NUMBER(6)     NOT NULL,
    CityName     VARCHAR2(80)  NOT NULL,
    RegionName   VARCHAR2(80),
    CountryKey   NUMBER(3)     NOT NULL
);

COMMENT ON TABLE ORG08_PostingStatus IS 'Stan ogłoszenia.';
COMMENT ON COLUMN ORG08_PostingStatus.PostingStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_PostingStatus.PostingStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG08_SeniorityLevel IS 'Poziom stanowiska.';
COMMENT ON COLUMN ORG08_SeniorityLevel.SeniorityLevelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_SeniorityLevel.SeniorityLevelName IS 'Nazwa poziomu';
COMMENT ON COLUMN ORG08_SeniorityLevel.SeniorityRank IS 'Kolejność poziomów (1 = najniższy)';

COMMENT ON TABLE ORG08_JobPosting IS 'Ogłoszenie o pracę opublikowane przez konto na platformie.';
COMMENT ON COLUMN ORG08_JobPosting.JobPostingKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_JobPosting.EmployerAccountKey IS 'Konto, które opublikowało ogłoszenie';
COMMENT ON COLUMN ORG08_JobPosting.ExternalPostingId IS 'Numer ogłoszenia w serwisie';
COMMENT ON COLUMN ORG08_JobPosting.PostingTitle IS 'Tytuł (aktualny)';
COMMENT ON COLUMN ORG08_JobPosting.PostingStatusKey IS 'Stan ogłoszenia';
COMMENT ON COLUMN ORG08_JobPosting.SeniorityLevelKey IS 'Poziom stanowiska (bywa niepodany)';
COMMENT ON COLUMN ORG08_JobPosting.WorkModeKey IS 'Tryb pracy (bywa niepodany)';
COMMENT ON COLUMN ORG08_JobPosting.VacancyCount IS 'Ilu osób szuka';
COMMENT ON COLUMN ORG08_JobPosting.PublishedDate IS 'Data pierwszej publikacji';
COMMENT ON COLUMN ORG08_JobPosting.ExpiryDate IS 'Planowana data końca';
COMMENT ON COLUMN ORG08_JobPosting.RawRecordKey IS 'Rekord, z którego powstało ogłoszenie';

COMMENT ON TABLE ORG08_WorkMode IS 'Tryb pracy.';
COMMENT ON COLUMN ORG08_WorkMode.WorkModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_WorkMode.WorkModeName IS 'Nazwa trybu pracy';

COMMENT ON TABLE ORG08_PostingLocation IS 'Miejsce pracy w ogłoszeniu – tabela łącząca ogłoszenia z miejscowościami.';
COMMENT ON COLUMN ORG08_PostingLocation.PostingLocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_PostingLocation.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG08_PostingLocation.LocationKey IS 'Miejscowość';
COMMENT ON COLUMN ORG08_PostingLocation.IsMainLocation IS 'Czy to główne miejsce pracy';

COMMENT ON TABLE ORG08_Location IS 'Miejscowość.';
COMMENT ON COLUMN ORG08_Location.LocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_Location.CityName IS 'Miejscowość';
COMMENT ON COLUMN ORG08_Location.RegionName IS 'Województwo albo region';
COMMENT ON COLUMN ORG08_Location.CountryKey IS 'Kraj';

ALTER TABLE ORG08_PostingStatus ADD CONSTRAINT ORG08_PostingStatus_PK PRIMARY KEY (PostingStatusKey);
ALTER TABLE ORG08_PostingStatus ADD CONSTRAINT ORG08_PostingStatus_PostingStatusName_UN UNIQUE (PostingStatusName);
ALTER TABLE ORG08_SeniorityLevel ADD CONSTRAINT ORG08_SeniorityLevel_PK PRIMARY KEY (SeniorityLevelKey);
ALTER TABLE ORG08_SeniorityLevel ADD CONSTRAINT ORG08_SeniorityLevel_SeniorityLevelName_UN UNIQUE (SeniorityLevelName);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_PK PRIMARY KEY (JobPostingKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_UN UNIQUE (EmployerAccountKey, ExternalPostingId);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_CK1 CHECK (ExpiryDate IS NULL OR ExpiryDate >= PublishedDate);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_CK2 CHECK (VacancyCount > 0);
ALTER TABLE ORG08_WorkMode ADD CONSTRAINT ORG08_WorkMode_PK PRIMARY KEY (WorkModeKey);
ALTER TABLE ORG08_WorkMode ADD CONSTRAINT ORG08_WorkMode_WorkModeName_UN UNIQUE (WorkModeName);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_PK PRIMARY KEY (PostingLocationKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_UN UNIQUE (JobPostingKey, LocationKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_IsMainLocation_CK CHECK (IsMainLocation IN ('T', 'N'));
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_PK PRIMARY KEY (LocationKey);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_UN UNIQUE (CityName, RegionName, CountryKey);

ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_PostingStatus_FK FOREIGN KEY (PostingStatusKey) REFERENCES ORG08_PostingStatus (PostingStatusKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_SeniorityLevel_FK FOREIGN KEY (SeniorityLevelKey) REFERENCES ORG08_SeniorityLevel (SeniorityLevelKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_WorkMode_FK FOREIGN KEY (WorkModeKey) REFERENCES ORG08_WorkMode (WorkModeKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_Location_FK FOREIGN KEY (LocationKey) REFERENCES ORG08_Location (LocationKey);

-- Organizm 9: Warunki zatrudnienia
-- Na jakiej umowie, za ile i z jakimi dodatkami – obietnica, którą firma składa w ogłoszeniu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG09_Currency (
    CurrencyKey   NUMBER(3)     NOT NULL,
    CurrencyCode  CHAR(3)       NOT NULL,
    CurrencyName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG09_ContractType (
    ContractTypeKey   NUMBER(2)     NOT NULL,
    ContractTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG09_SalaryPeriod (
    SalaryPeriodKey   NUMBER(2)     NOT NULL,
    SalaryPeriodName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG09_PostingSalary (
    PostingSalaryKey  NUMBER(11)    NOT NULL,
    JobPostingKey     NUMBER(10)    NOT NULL,
    ContractTypeKey   NUMBER(2)     NOT NULL,
    SalaryFrom        NUMBER(10,2),
    SalaryTo          NUMBER(10,2),
    CurrencyKey       NUMBER(3),
    SalaryPeriodKey   NUMBER(2),
    IsGross           CHAR(1)
);

CREATE TABLE ORG09_PostingBenefit (
    PostingBenefitKey  NUMBER(11)  NOT NULL,
    JobPostingKey      NUMBER(10)  NOT NULL,
    BenefitKey         NUMBER(4)   NOT NULL
);

CREATE TABLE ORG09_Benefit (
    BenefitKey          NUMBER(4)     NOT NULL,
    BenefitName         VARCHAR2(80)  NOT NULL,
    BenefitCategoryKey  NUMBER(2)     NOT NULL
);

CREATE TABLE ORG09_BenefitCategory (
    BenefitCategoryKey   NUMBER(2)     NOT NULL,
    BenefitCategoryName  VARCHAR2(30)  NOT NULL
);

COMMENT ON TABLE ORG09_Currency IS 'Waluta.';
COMMENT ON COLUMN ORG09_Currency.CurrencyKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_Currency.CurrencyCode IS 'Kod waluty ISO, np. PLN';
COMMENT ON COLUMN ORG09_Currency.CurrencyName IS 'Nazwa waluty';

COMMENT ON TABLE ORG09_ContractType IS 'Rodzaj umowy.';
COMMENT ON COLUMN ORG09_ContractType.ContractTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_ContractType.ContractTypeName IS 'Nazwa rodzaju umowy';

COMMENT ON TABLE ORG09_SalaryPeriod IS 'Okres, za który podano kwotę.';
COMMENT ON COLUMN ORG09_SalaryPeriod.SalaryPeriodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_SalaryPeriod.SalaryPeriodName IS 'Nazwa okresu';

COMMENT ON TABLE ORG09_PostingSalary IS 'Umowa z widełkami w ogłoszeniu – jedno ogłoszenie może mieć kilka takich wierszy.';
COMMENT ON COLUMN ORG09_PostingSalary.PostingSalaryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_PostingSalary.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG09_PostingSalary.ContractTypeKey IS 'Rodzaj umowy';
COMMENT ON COLUMN ORG09_PostingSalary.SalaryFrom IS 'Widełki od (puste = nie podano)';
COMMENT ON COLUMN ORG09_PostingSalary.SalaryTo IS 'Widełki do';
COMMENT ON COLUMN ORG09_PostingSalary.CurrencyKey IS 'Waluta (puste, gdy brak kwoty)';
COMMENT ON COLUMN ORG09_PostingSalary.SalaryPeriodKey IS 'Za jaki okres (puste, gdy brak kwoty)';
COMMENT ON COLUMN ORG09_PostingSalary.IsGross IS 'Czy kwota jest brutto';

COMMENT ON TABLE ORG09_PostingBenefit IS 'Benefit w ogłoszeniu – tabela łącząca ogłoszenia z benefitami.';
COMMENT ON COLUMN ORG09_PostingBenefit.PostingBenefitKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_PostingBenefit.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG09_PostingBenefit.BenefitKey IS 'Benefit';

COMMENT ON TABLE ORG09_Benefit IS 'Dodatek do pracy, np. prywatna opieka medyczna.';
COMMENT ON COLUMN ORG09_Benefit.BenefitKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_Benefit.BenefitName IS 'Nazwa benefitu';
COMMENT ON COLUMN ORG09_Benefit.BenefitCategoryKey IS 'Grupa benefitu';

COMMENT ON TABLE ORG09_BenefitCategory IS 'Grupa benefitów.';
COMMENT ON COLUMN ORG09_BenefitCategory.BenefitCategoryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_BenefitCategory.BenefitCategoryName IS 'Nazwa grupy';

ALTER TABLE ORG09_Currency ADD CONSTRAINT ORG09_Currency_PK PRIMARY KEY (CurrencyKey);
ALTER TABLE ORG09_Currency ADD CONSTRAINT ORG09_Currency_CurrencyCode_UN UNIQUE (CurrencyCode);
ALTER TABLE ORG09_ContractType ADD CONSTRAINT ORG09_ContractType_PK PRIMARY KEY (ContractTypeKey);
ALTER TABLE ORG09_ContractType ADD CONSTRAINT ORG09_ContractType_ContractTypeName_UN UNIQUE (ContractTypeName);
ALTER TABLE ORG09_SalaryPeriod ADD CONSTRAINT ORG09_SalaryPeriod_PK PRIMARY KEY (SalaryPeriodKey);
ALTER TABLE ORG09_SalaryPeriod ADD CONSTRAINT ORG09_SalaryPeriod_SalaryPeriodName_UN UNIQUE (SalaryPeriodName);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_PK PRIMARY KEY (PostingSalaryKey);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_UN UNIQUE (JobPostingKey, ContractTypeKey);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_IsGross_CK CHECK (IsGross IN ('T', 'N'));
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_CK1 CHECK (SalaryFrom IS NULL OR SalaryTo IS NULL OR SalaryFrom <= SalaryTo);
ALTER TABLE ORG09_PostingBenefit ADD CONSTRAINT ORG09_PostingBenefit_PK PRIMARY KEY (PostingBenefitKey);
ALTER TABLE ORG09_PostingBenefit ADD CONSTRAINT ORG09_PostingBenefit_UN UNIQUE (JobPostingKey, BenefitKey);
ALTER TABLE ORG09_Benefit ADD CONSTRAINT ORG09_Benefit_PK PRIMARY KEY (BenefitKey);
ALTER TABLE ORG09_Benefit ADD CONSTRAINT ORG09_Benefit_BenefitName_UN UNIQUE (BenefitName);
ALTER TABLE ORG09_BenefitCategory ADD CONSTRAINT ORG09_BenefitCategory_PK PRIMARY KEY (BenefitCategoryKey);
ALTER TABLE ORG09_BenefitCategory ADD CONSTRAINT ORG09_BenefitCategory_BenefitCategoryName_UN UNIQUE (BenefitCategoryName);

ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_ContractType_FK FOREIGN KEY (ContractTypeKey) REFERENCES ORG09_ContractType (ContractTypeKey);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_Currency_FK FOREIGN KEY (CurrencyKey) REFERENCES ORG09_Currency (CurrencyKey);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_SalaryPeriod_FK FOREIGN KEY (SalaryPeriodKey) REFERENCES ORG09_SalaryPeriod (SalaryPeriodKey);
ALTER TABLE ORG09_PostingBenefit ADD CONSTRAINT ORG09_PostingBenefit_Benefit_FK FOREIGN KEY (BenefitKey) REFERENCES ORG09_Benefit (BenefitKey);
ALTER TABLE ORG09_Benefit ADD CONSTRAINT ORG09_Benefit_BenefitCategory_FK FOREIGN KEY (BenefitCategoryKey) REFERENCES ORG09_BenefitCategory (BenefitCategoryKey);

-- Organizm 10: Wymagania i obowiązki
-- Czego firma oczekuje od kandydata i co ma on robić – rozpisane na pola, żeby dało się porównywać.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG10_RequirementLevel (
    RequirementLevelKey   NUMBER(2)     NOT NULL,
    RequirementLevelName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG10_PostingResponsibility (
    PostingResponsibilityKey  NUMBER(11)     NOT NULL,
    JobPostingKey             NUMBER(10)     NOT NULL,
    ResponsibilityText        VARCHAR2(400)  NOT NULL,
    ExtractionMethodKey       NUMBER(2)      NOT NULL
);

CREATE TABLE ORG10_ProficiencyLevel (
    ProficiencyLevelKey   NUMBER(3)     NOT NULL,
    ProficiencyLevelName  VARCHAR2(40)  NOT NULL,
    SkillCategoryKey      NUMBER(2)     NOT NULL,
    ProficiencyRank       NUMBER(2)     NOT NULL
);

CREATE TABLE ORG10_PostingRequirement (
    PostingRequirementKey  NUMBER(11)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    SkillKey               NUMBER(6)   NOT NULL,
    RequirementLevelKey    NUMBER(2)   NOT NULL,
    ProficiencyLevelKey    NUMBER(3),
    MinYearsExperience     NUMBER(2),
    ExtractionMethodKey    NUMBER(2)   NOT NULL
);

CREATE TABLE ORG10_ExtractionMethod (
    ExtractionMethodKey   NUMBER(2)     NOT NULL,
    ExtractionMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG10_SkillCategory (
    SkillCategoryKey   NUMBER(2)     NOT NULL,
    SkillCategoryName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG10_Skill (
    SkillKey          NUMBER(6)     NOT NULL,
    SkillName         VARCHAR2(80)  NOT NULL,
    SkillCategoryKey  NUMBER(2)     NOT NULL
);

CREATE TABLE ORG10_SkillSynonym (
    SkillSynonymKey  NUMBER(7)     NOT NULL,
    SkillKey         NUMBER(6)     NOT NULL,
    SynonymText      VARCHAR2(80)  NOT NULL
);

COMMENT ON TABLE ORG10_RequirementLevel IS 'Ważność wymagania.';
COMMENT ON COLUMN ORG10_RequirementLevel.RequirementLevelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_RequirementLevel.RequirementLevelName IS 'Nazwa ważności';

COMMENT ON TABLE ORG10_PostingResponsibility IS 'Obowiązek opisany w ogłoszeniu.';
COMMENT ON COLUMN ORG10_PostingResponsibility.PostingResponsibilityKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_PostingResponsibility.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG10_PostingResponsibility.ResponsibilityText IS 'Treść obowiązku';
COMMENT ON COLUMN ORG10_PostingResponsibility.ExtractionMethodKey IS 'Skąd wiemy';

COMMENT ON TABLE ORG10_ProficiencyLevel IS 'Poziom znajomości – każda grupa umiejętności ma własną skalę.';
COMMENT ON COLUMN ORG10_ProficiencyLevel.ProficiencyLevelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_ProficiencyLevel.ProficiencyLevelName IS 'Nazwa poziomu, np. B2';
COMMENT ON COLUMN ORG10_ProficiencyLevel.SkillCategoryKey IS 'Dla jakiej grupy umiejętności';
COMMENT ON COLUMN ORG10_ProficiencyLevel.ProficiencyRank IS 'Kolejność w skali (1 = najniższy)';

COMMENT ON TABLE ORG10_PostingRequirement IS 'Wymaganie w ogłoszeniu.';
COMMENT ON COLUMN ORG10_PostingRequirement.PostingRequirementKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_PostingRequirement.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG10_PostingRequirement.SkillKey IS 'Umiejętność';
COMMENT ON COLUMN ORG10_PostingRequirement.RequirementLevelKey IS 'Wymagane czy mile widziane';
COMMENT ON COLUMN ORG10_PostingRequirement.ProficiencyLevelKey IS 'Poziom (bywa niepodany)';
COMMENT ON COLUMN ORG10_PostingRequirement.MinYearsExperience IS 'Minimalne doświadczenie w latach';
COMMENT ON COLUMN ORG10_PostingRequirement.ExtractionMethodKey IS 'Skąd wiemy';

COMMENT ON TABLE ORG10_ExtractionMethod IS 'Skąd pochodzi informacja.';
COMMENT ON COLUMN ORG10_ExtractionMethod.ExtractionMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_ExtractionMethod.ExtractionMethodName IS 'Nazwa źródła informacji';

COMMENT ON TABLE ORG10_SkillCategory IS 'Grupa umiejętności.';
COMMENT ON COLUMN ORG10_SkillCategory.SkillCategoryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_SkillCategory.SkillCategoryName IS 'Nazwa grupy';

COMMENT ON TABLE ORG10_Skill IS 'Umiejętność albo kwalifikacja.';
COMMENT ON COLUMN ORG10_Skill.SkillKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_Skill.SkillName IS 'Nazwa';
COMMENT ON COLUMN ORG10_Skill.SkillCategoryKey IS 'Grupa';

COMMENT ON TABLE ORG10_SkillSynonym IS 'Inny zapis tej samej umiejętności.';
COMMENT ON COLUMN ORG10_SkillSynonym.SkillSynonymKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG10_SkillSynonym.SkillKey IS 'Umiejętność';
COMMENT ON COLUMN ORG10_SkillSynonym.SynonymText IS 'Zapis spotykany w ogłoszeniach';

ALTER TABLE ORG10_RequirementLevel ADD CONSTRAINT ORG10_RequirementLevel_PK PRIMARY KEY (RequirementLevelKey);
ALTER TABLE ORG10_RequirementLevel ADD CONSTRAINT ORG10_RequirementLevel_RequirementLevelName_UN UNIQUE (RequirementLevelName);
ALTER TABLE ORG10_PostingResponsibility ADD CONSTRAINT ORG10_PostingResponsibility_PK PRIMARY KEY (PostingResponsibilityKey);
ALTER TABLE ORG10_ProficiencyLevel ADD CONSTRAINT ORG10_ProficiencyLevel_PK PRIMARY KEY (ProficiencyLevelKey);
ALTER TABLE ORG10_ProficiencyLevel ADD CONSTRAINT ORG10_ProficiencyLevel_UN UNIQUE (SkillCategoryKey, ProficiencyLevelName);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_PK PRIMARY KEY (PostingRequirementKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_UN UNIQUE (JobPostingKey, SkillKey);
ALTER TABLE ORG10_ExtractionMethod ADD CONSTRAINT ORG10_ExtractionMethod_PK PRIMARY KEY (ExtractionMethodKey);
ALTER TABLE ORG10_ExtractionMethod ADD CONSTRAINT ORG10_ExtractionMethod_ExtractionMethodName_UN UNIQUE (ExtractionMethodName);
ALTER TABLE ORG10_SkillCategory ADD CONSTRAINT ORG10_SkillCategory_PK PRIMARY KEY (SkillCategoryKey);
ALTER TABLE ORG10_SkillCategory ADD CONSTRAINT ORG10_SkillCategory_SkillCategoryName_UN UNIQUE (SkillCategoryName);
ALTER TABLE ORG10_Skill ADD CONSTRAINT ORG10_Skill_PK PRIMARY KEY (SkillKey);
ALTER TABLE ORG10_Skill ADD CONSTRAINT ORG10_Skill_SkillName_UN UNIQUE (SkillName);
ALTER TABLE ORG10_SkillSynonym ADD CONSTRAINT ORG10_SkillSynonym_PK PRIMARY KEY (SkillSynonymKey);
ALTER TABLE ORG10_SkillSynonym ADD CONSTRAINT ORG10_SkillSynonym_SynonymText_UN UNIQUE (SynonymText);

ALTER TABLE ORG10_PostingResponsibility ADD CONSTRAINT ORG10_PostingResponsibility_ExtractionMethod_FK FOREIGN KEY (ExtractionMethodKey) REFERENCES ORG10_ExtractionMethod (ExtractionMethodKey);
ALTER TABLE ORG10_ProficiencyLevel ADD CONSTRAINT ORG10_ProficiencyLevel_SkillCategory_FK FOREIGN KEY (SkillCategoryKey) REFERENCES ORG10_SkillCategory (SkillCategoryKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_Skill_FK FOREIGN KEY (SkillKey) REFERENCES ORG10_Skill (SkillKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_RequirementLevel_FK FOREIGN KEY (RequirementLevelKey) REFERENCES ORG10_RequirementLevel (RequirementLevelKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_ProficiencyLevel_FK FOREIGN KEY (ProficiencyLevelKey) REFERENCES ORG10_ProficiencyLevel (ProficiencyLevelKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_ExtractionMethod_FK FOREIGN KEY (ExtractionMethodKey) REFERENCES ORG10_ExtractionMethod (ExtractionMethodKey);
ALTER TABLE ORG10_Skill ADD CONSTRAINT ORG10_Skill_SkillCategory_FK FOREIGN KEY (SkillCategoryKey) REFERENCES ORG10_SkillCategory (SkillCategoryKey);
ALTER TABLE ORG10_SkillSynonym ADD CONSTRAINT ORG10_SkillSynonym_Skill_FK FOREIGN KEY (SkillKey) REFERENCES ORG10_Skill (SkillKey);

-- Organizm 11: Historia i treść ogłoszenia
-- Co działo się z ogłoszeniem w czasie i jak zmieniała się jego treść.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG11_EventSource (
    EventSourceKey   NUMBER(2)     NOT NULL,
    EventSourceName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG11_PostingEventType (
    PostingEventTypeKey   NUMBER(2)     NOT NULL,
    PostingEventTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG11_PostingEvent (
    PostingEventKey      NUMBER(12)  NOT NULL,
    JobPostingKey        NUMBER(10)  NOT NULL,
    PostingEventTypeKey  NUMBER(2)   NOT NULL,
    EventSourceKey       NUMBER(2)   NOT NULL,
    OccurredAt           TIMESTAMP   NOT NULL,
    DataDeliveryKey      NUMBER(10)
);

CREATE TABLE ORG11_PostingVersion (
    PostingVersionKey  NUMBER(11)     NOT NULL,
    JobPostingKey      NUMBER(10)     NOT NULL,
    VersionNumber      NUMBER(3)      NOT NULL,
    VersionTitle       VARCHAR2(200)  NOT NULL,
    OriginalText       CLOB           NOT NULL,
    CleanText          CLOB,
    TextHash           VARCHAR2(64)   NOT NULL,
    ValidFrom          TIMESTAMP      NOT NULL,
    ValidTo            TIMESTAMP
);

CREATE TABLE ORG11_BoilerplatePattern (
    BoilerplatePatternKey  NUMBER(6)       NOT NULL,
    BoilerplateTypeKey     NUMBER(2)       NOT NULL,
    PatternText            VARCHAR2(1000)  NOT NULL,
    EmployerKey            NUMBER(8)
);

CREATE TABLE ORG11_VersionBoilerplate (
    VersionBoilerplateKey  NUMBER(12)  NOT NULL,
    PostingVersionKey      NUMBER(11)  NOT NULL,
    BoilerplatePatternKey  NUMBER(6)   NOT NULL
);

CREATE TABLE ORG11_BoilerplateType (
    BoilerplateTypeKey   NUMBER(2)     NOT NULL,
    BoilerplateTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG11_EventSource IS 'Kto powiedział nam o zdarzeniu.';
COMMENT ON COLUMN ORG11_EventSource.EventSourceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_EventSource.EventSourceName IS 'Nazwa źródła zdarzenia';

COMMENT ON TABLE ORG11_PostingEventType IS 'Rodzaj zdarzenia w życiu ogłoszenia.';
COMMENT ON COLUMN ORG11_PostingEventType.PostingEventTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_PostingEventType.PostingEventTypeName IS 'Nazwa zdarzenia';

COMMENT ON TABLE ORG11_PostingEvent IS 'Zdarzenie w życiu ogłoszenia – tylko dopisujemy, nic nie zmieniamy.';
COMMENT ON COLUMN ORG11_PostingEvent.PostingEventKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_PostingEvent.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG11_PostingEvent.PostingEventTypeKey IS 'Co się stało';
COMMENT ON COLUMN ORG11_PostingEvent.EventSourceKey IS 'Skąd wiemy';
COMMENT ON COLUMN ORG11_PostingEvent.OccurredAt IS 'Kiedy';
COMMENT ON COLUMN ORG11_PostingEvent.DataDeliveryKey IS 'W której dostawie przyszła informacja';

COMMENT ON TABLE ORG11_PostingVersion IS 'Wersja treści ogłoszenia – każda edycja to nowy wiersz.';
COMMENT ON COLUMN ORG11_PostingVersion.PostingVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_PostingVersion.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG11_PostingVersion.VersionNumber IS 'Numer wersji (1, 2, 3…)';
COMMENT ON COLUMN ORG11_PostingVersion.VersionTitle IS 'Tytuł w tej wersji';
COMMENT ON COLUMN ORG11_PostingVersion.OriginalText IS 'Treść tak, jak przyszła';
COMMENT ON COLUMN ORG11_PostingVersion.CleanText IS 'Treść bez stopek i klauzul';
COMMENT ON COLUMN ORG11_PostingVersion.TextHash IS 'Skrót treści – szybkie porównanie wersji';
COMMENT ON COLUMN ORG11_PostingVersion.ValidFrom IS 'Od kiedy treść była taka';
COMMENT ON COLUMN ORG11_PostingVersion.ValidTo IS 'Do kiedy (puste = aktualna)';

COMMENT ON TABLE ORG11_BoilerplatePattern IS 'Powtarzalny fragment tekstu do rozpoznania w ogłoszeniach.';
COMMENT ON COLUMN ORG11_BoilerplatePattern.BoilerplatePatternKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_BoilerplatePattern.BoilerplateTypeKey IS 'Rodzaj fragmentu';
COMMENT ON COLUMN ORG11_BoilerplatePattern.PatternText IS 'Treść albo wzorzec fragmentu';
COMMENT ON COLUMN ORG11_BoilerplatePattern.EmployerKey IS 'Firma, której to fragment (puste = wzorzec ogólny)';

COMMENT ON TABLE ORG11_VersionBoilerplate IS 'Fragment znaleziony w wersji ogłoszenia – tabela łącząca.';
COMMENT ON COLUMN ORG11_VersionBoilerplate.VersionBoilerplateKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_VersionBoilerplate.PostingVersionKey IS 'Wersja ogłoszenia';
COMMENT ON COLUMN ORG11_VersionBoilerplate.BoilerplatePatternKey IS 'Znaleziony fragment';

COMMENT ON TABLE ORG11_BoilerplateType IS 'Rodzaj powtarzalnego fragmentu.';
COMMENT ON COLUMN ORG11_BoilerplateType.BoilerplateTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_BoilerplateType.BoilerplateTypeName IS 'Nazwa rodzaju fragmentu';

ALTER TABLE ORG11_EventSource ADD CONSTRAINT ORG11_EventSource_PK PRIMARY KEY (EventSourceKey);
ALTER TABLE ORG11_EventSource ADD CONSTRAINT ORG11_EventSource_EventSourceName_UN UNIQUE (EventSourceName);
ALTER TABLE ORG11_PostingEventType ADD CONSTRAINT ORG11_PostingEventType_PK PRIMARY KEY (PostingEventTypeKey);
ALTER TABLE ORG11_PostingEventType ADD CONSTRAINT ORG11_PostingEventType_PostingEventTypeName_UN UNIQUE (PostingEventTypeName);
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_PK PRIMARY KEY (PostingEventKey);
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_PK PRIMARY KEY (PostingVersionKey);
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_UN UNIQUE (JobPostingKey, VersionNumber);
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo > ValidFrom);
ALTER TABLE ORG11_BoilerplatePattern ADD CONSTRAINT ORG11_BoilerplatePattern_PK PRIMARY KEY (BoilerplatePatternKey);
ALTER TABLE ORG11_VersionBoilerplate ADD CONSTRAINT ORG11_VersionBoilerplate_PK PRIMARY KEY (VersionBoilerplateKey);
ALTER TABLE ORG11_VersionBoilerplate ADD CONSTRAINT ORG11_VersionBoilerplate_UN UNIQUE (PostingVersionKey, BoilerplatePatternKey);
ALTER TABLE ORG11_BoilerplateType ADD CONSTRAINT ORG11_BoilerplateType_PK PRIMARY KEY (BoilerplateTypeKey);
ALTER TABLE ORG11_BoilerplateType ADD CONSTRAINT ORG11_BoilerplateType_BoilerplateTypeName_UN UNIQUE (BoilerplateTypeName);

ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_PostingEventType_FK FOREIGN KEY (PostingEventTypeKey) REFERENCES ORG11_PostingEventType (PostingEventTypeKey);
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_EventSource_FK FOREIGN KEY (EventSourceKey) REFERENCES ORG11_EventSource (EventSourceKey);
ALTER TABLE ORG11_BoilerplatePattern ADD CONSTRAINT ORG11_BoilerplatePattern_BoilerplateType_FK FOREIGN KEY (BoilerplateTypeKey) REFERENCES ORG11_BoilerplateType (BoilerplateTypeKey);
ALTER TABLE ORG11_VersionBoilerplate ADD CONSTRAINT ORG11_VersionBoilerplate_PostingVersion_FK FOREIGN KEY (PostingVersionKey) REFERENCES ORG11_PostingVersion (PostingVersionKey);
ALTER TABLE ORG11_VersionBoilerplate ADD CONSTRAINT ORG11_VersionBoilerplate_BoilerplatePattern_FK FOREIGN KEY (BoilerplatePatternKey) REFERENCES ORG11_BoilerplatePattern (BoilerplatePatternKey);

-- Organizm 12: Podobne ogłoszenia i rodziny
-- Które ogłoszenia są powtórkami i jak długo to samo stanowisko krąży po platformach.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG12_SimilarityType (
    SimilarityTypeKey   NUMBER(2)     NOT NULL,
    SimilarityTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG12_SimilarityMethod (
    SimilarityMethodKey   NUMBER(3)     NOT NULL,
    SimilarityMethodName  VARCHAR2(60)  NOT NULL,
    MethodVersion         VARCHAR2(20)  NOT NULL,
    ValidFrom             DATE          NOT NULL
);

CREATE TABLE ORG12_SimilarityPair (
    SimilarityPairKey    NUMBER(12)   NOT NULL,
    FirstJobPostingKey   NUMBER(10)   NOT NULL,
    SecondJobPostingKey  NUMBER(10)   NOT NULL,
    SimilarityTypeKey    NUMBER(2)    NOT NULL,
    SimilarityMethodKey  NUMBER(3)    NOT NULL,
    SimilarityScore      NUMBER(4,3)  NOT NULL,
    DetectedAt           TIMESTAMP    NOT NULL
);

CREATE TABLE ORG12_FamilyMember (
    FamilyMemberKey   NUMBER(11)  NOT NULL,
    PostingFamilyKey  NUMBER(9)   NOT NULL,
    JobPostingKey     NUMBER(10)  NOT NULL,
    AddedAt           TIMESTAMP   NOT NULL
);

CREATE TABLE ORG12_PostingFamily (
    PostingFamilyKey  NUMBER(9)      NOT NULL,
    EmployerKey       NUMBER(8)      NOT NULL,
    FamilyLabel       VARCHAR2(200)  NOT NULL,
    FirstSeenDate     DATE           NOT NULL,
    LastSeenDate      DATE           NOT NULL
);

CREATE TABLE ORG12_FamilyLifecycle (
    FamilyLifecycleKey     NUMBER(10)  NOT NULL,
    PostingFamilyKey       NUMBER(9)   NOT NULL,
    CalculatedOn           DATE        NOT NULL,
    PublicationCount       NUMBER(4)   NOT NULL,
    VisibleDays            NUMBER(5)   NOT NULL,
    GapCount               NUMBER(4)   NOT NULL,
    RefreshCount           NUMBER(5)   NOT NULL,
    PlatformCount          NUMBER(3)   NOT NULL,
    SeniorityVariantCount  NUMBER(2)   NOT NULL
);

COMMENT ON TABLE ORG12_SimilarityType IS 'Rodzaj powtórki.';
COMMENT ON COLUMN ORG12_SimilarityType.SimilarityTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityType.SimilarityTypeName IS 'Nazwa rodzaju powtórki';

COMMENT ON TABLE ORG12_SimilarityMethod IS 'Metoda liczenia podobieństwa w konkretnej wersji.';
COMMENT ON COLUMN ORG12_SimilarityMethod.SimilarityMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityMethod.SimilarityMethodName IS 'Nazwa metody';
COMMENT ON COLUMN ORG12_SimilarityMethod.MethodVersion IS 'Wersja metody';
COMMENT ON COLUMN ORG12_SimilarityMethod.ValidFrom IS 'Od kiedy używana';

COMMENT ON TABLE ORG12_SimilarityPair IS 'Para podobnych ogłoszeń – dwa klucze obce do tej samej tabeli.';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityPairKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityPair.FirstJobPostingKey IS 'Pierwsze ogłoszenie (wcześniejsze)';
COMMENT ON COLUMN ORG12_SimilarityPair.SecondJobPostingKey IS 'Drugie ogłoszenie';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityTypeKey IS 'Rodzaj powtórki';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityMethodKey IS 'Metoda';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityScore IS 'Podobieństwo od 0 do 1';
COMMENT ON COLUMN ORG12_SimilarityPair.DetectedAt IS 'Kiedy wykryto';

COMMENT ON TABLE ORG12_FamilyMember IS 'Ogłoszenie w rodzinie – tabela łącząca.';
COMMENT ON COLUMN ORG12_FamilyMember.FamilyMemberKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_FamilyMember.PostingFamilyKey IS 'Rodzina';
COMMENT ON COLUMN ORG12_FamilyMember.JobPostingKey IS 'Ogłoszenie (najwyżej w jednej rodzinie)';
COMMENT ON COLUMN ORG12_FamilyMember.AddedAt IS 'Kiedy dołączono do rodziny';

COMMENT ON TABLE ORG12_PostingFamily IS 'Rodzina ogłoszeń – to samo stanowisko jednej firmy w czasie.';
COMMENT ON COLUMN ORG12_PostingFamily.PostingFamilyKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_PostingFamily.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG12_PostingFamily.FamilyLabel IS 'Opis stanowiska, np. „Księgowa, Kraków”';
COMMENT ON COLUMN ORG12_PostingFamily.FirstSeenDate IS 'Pierwsza publikacja';
COMMENT ON COLUMN ORG12_PostingFamily.LastSeenDate IS 'Ostatnia publikacja';

COMMENT ON TABLE ORG12_FamilyLifecycle IS 'Historia rodziny policzona na dany dzień.';
COMMENT ON COLUMN ORG12_FamilyLifecycle.FamilyLifecycleKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_FamilyLifecycle.PostingFamilyKey IS 'Rodzina';
COMMENT ON COLUMN ORG12_FamilyLifecycle.CalculatedOn IS 'Dzień obliczenia';
COMMENT ON COLUMN ORG12_FamilyLifecycle.PublicationCount IS 'Ile razy publikowano';
COMMENT ON COLUMN ORG12_FamilyLifecycle.VisibleDays IS 'Ile dni łącznie było widoczne';
COMMENT ON COLUMN ORG12_FamilyLifecycle.GapCount IS 'Ile razy znikało i wracało';
COMMENT ON COLUMN ORG12_FamilyLifecycle.RefreshCount IS 'Ile razy odświeżano';
COMMENT ON COLUMN ORG12_FamilyLifecycle.PlatformCount IS 'Na ilu platformach';
COMMENT ON COLUMN ORG12_FamilyLifecycle.SeniorityVariantCount IS 'Ile różnych poziomów stanowiska';

ALTER TABLE ORG12_SimilarityType ADD CONSTRAINT ORG12_SimilarityType_PK PRIMARY KEY (SimilarityTypeKey);
ALTER TABLE ORG12_SimilarityType ADD CONSTRAINT ORG12_SimilarityType_SimilarityTypeName_UN UNIQUE (SimilarityTypeName);
ALTER TABLE ORG12_SimilarityMethod ADD CONSTRAINT ORG12_SimilarityMethod_PK PRIMARY KEY (SimilarityMethodKey);
ALTER TABLE ORG12_SimilarityMethod ADD CONSTRAINT ORG12_SimilarityMethod_UN UNIQUE (SimilarityMethodName, MethodVersion);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_PK PRIMARY KEY (SimilarityPairKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_UN UNIQUE (FirstJobPostingKey, SecondJobPostingKey, SimilarityMethodKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_CK1 CHECK (FirstJobPostingKey < SecondJobPostingKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_CK2 CHECK (SimilarityScore BETWEEN 0 AND 1);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_PK PRIMARY KEY (FamilyMemberKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_JobPostingKey_UN UNIQUE (JobPostingKey);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_PK PRIMARY KEY (PostingFamilyKey);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_CK1 CHECK (LastSeenDate >= FirstSeenDate);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_PK PRIMARY KEY (FamilyLifecycleKey);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_UN UNIQUE (PostingFamilyKey, CalculatedOn);

ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SimilarityType_FK FOREIGN KEY (SimilarityTypeKey) REFERENCES ORG12_SimilarityType (SimilarityTypeKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SimilarityMethod_FK FOREIGN KEY (SimilarityMethodKey) REFERENCES ORG12_SimilarityMethod (SimilarityMethodKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES ORG12_PostingFamily (PostingFamilyKey);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES ORG12_PostingFamily (PostingFamilyKey);

-- Organizm 13: Kandydat, aplikacje i zgody
-- Osoba znana tylko z pseudonimu, jej aplikacje potwierdzone przez platformę i jej zgody.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG13_CandidatePseudonym (
    CandidatePseudonymKey  NUMBER(10)    NOT NULL,
    SourcePlatformKey      NUMBER(4)     NOT NULL,
    PseudonymValue         VARCHAR2(64)  NOT NULL,
    FirstSeenAt            TIMESTAMP     NOT NULL
);

CREATE TABLE ORG13_Application (
    ApplicationKey         NUMBER(12)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    AppliedAt              TIMESTAMP   NOT NULL,
    DataDeliveryKey        NUMBER(10)
);

CREATE TABLE ORG13_Consent (
    ConsentKey             NUMBER(11)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    ConsentTextVersionKey  NUMBER(4)   NOT NULL,
    IsGranted              CHAR(1)     NOT NULL,
    DecidedAt              TIMESTAMP   NOT NULL
);

CREATE TABLE ORG13_ApplicationStatusChange (
    ApplicationStatusChangeKey  NUMBER(12)  NOT NULL,
    ApplicationKey              NUMBER(12)  NOT NULL,
    ApplicationStatusKey        NUMBER(2)   NOT NULL,
    ChangedAt                   TIMESTAMP   NOT NULL
);

CREATE TABLE ORG13_ApplicationStatus (
    ApplicationStatusKey   NUMBER(2)     NOT NULL,
    ApplicationStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG13_ConsentTextVersion (
    ConsentTextVersionKey  NUMBER(4)     NOT NULL,
    ConsentTypeKey         NUMBER(2)     NOT NULL,
    VersionLabel           VARCHAR2(10)  NOT NULL,
    ConsentText            CLOB          NOT NULL,
    ValidFrom              DATE          NOT NULL
);

CREATE TABLE ORG13_ConsentType (
    ConsentTypeKey   NUMBER(2)     NOT NULL,
    ConsentTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG13_CandidatePseudonym IS 'Kandydat znany tylko z pseudonimu nadanego przez platformę.';
COMMENT ON COLUMN ORG13_CandidatePseudonym.CandidatePseudonymKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_CandidatePseudonym.SourcePlatformKey IS 'Platforma, która nadała pseudonim';
COMMENT ON COLUMN ORG13_CandidatePseudonym.PseudonymValue IS 'Ciąg znaków od platformy';
COMMENT ON COLUMN ORG13_CandidatePseudonym.FirstSeenAt IS 'Kiedy pierwszy raz się pojawił';

COMMENT ON TABLE ORG13_Application IS 'Aplikacja kandydata na ogłoszenie, potwierdzona przez platformę.';
COMMENT ON COLUMN ORG13_Application.ApplicationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_Application.CandidatePseudonymKey IS 'Kandydat';
COMMENT ON COLUMN ORG13_Application.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG13_Application.AppliedAt IS 'Kiedy aplikował';
COMMENT ON COLUMN ORG13_Application.DataDeliveryKey IS 'W której dostawie przyszła informacja';

COMMENT ON TABLE ORG13_Consent IS 'Decyzja kandydata o zgodzie – udzielenie albo wycofanie to nowy wiersz.';
COMMENT ON COLUMN ORG13_Consent.ConsentKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_Consent.CandidatePseudonymKey IS 'Kandydat';
COMMENT ON COLUMN ORG13_Consent.ConsentTextVersionKey IS 'Treść zgody, którą widział';
COMMENT ON COLUMN ORG13_Consent.IsGranted IS 'T = zgoda udzielona, N = wycofana';
COMMENT ON COLUMN ORG13_Consent.DecidedAt IS 'Kiedy';

COMMENT ON TABLE ORG13_ApplicationStatusChange IS 'Zmiana stanu aplikacji – historia.';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationStatusChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationKey IS 'Aplikacja';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationStatusKey IS 'Nowy stan';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ChangedAt IS 'Kiedy';

COMMENT ON TABLE ORG13_ApplicationStatus IS 'Stan aplikacji.';
COMMENT ON COLUMN ORG13_ApplicationStatus.ApplicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ApplicationStatus.ApplicationStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG13_ConsentTextVersion IS 'Wersja treści zgody, którą kandydat zobaczył.';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentTextVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentTypeKey IS 'Na co jest zgoda';
COMMENT ON COLUMN ORG13_ConsentTextVersion.VersionLabel IS 'Oznaczenie wersji, np. 1.2';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentText IS 'Pełna treść zgody';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ValidFrom IS 'Od kiedy pokazywana';

COMMENT ON TABLE ORG13_ConsentType IS 'Na co kandydat się zgadza.';
COMMENT ON COLUMN ORG13_ConsentType.ConsentTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ConsentType.ConsentTypeName IS 'Nazwa zgody';

ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_PK PRIMARY KEY (CandidatePseudonymKey);
ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_UN UNIQUE (SourcePlatformKey, PseudonymValue);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_PK PRIMARY KEY (ApplicationKey);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_UN UNIQUE (CandidatePseudonymKey, JobPostingKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_PK PRIMARY KEY (ConsentKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_IsGranted_CK CHECK (IsGranted IN ('T', 'N'));
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_PK PRIMARY KEY (ApplicationStatusChangeKey);
ALTER TABLE ORG13_ApplicationStatus ADD CONSTRAINT ORG13_ApplicationStatus_PK PRIMARY KEY (ApplicationStatusKey);
ALTER TABLE ORG13_ApplicationStatus ADD CONSTRAINT ORG13_ApplicationStatus_ApplicationStatusName_UN UNIQUE (ApplicationStatusName);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_PK PRIMARY KEY (ConsentTextVersionKey);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_UN UNIQUE (ConsentTypeKey, VersionLabel);
ALTER TABLE ORG13_ConsentType ADD CONSTRAINT ORG13_ConsentType_PK PRIMARY KEY (ConsentTypeKey);
ALTER TABLE ORG13_ConsentType ADD CONSTRAINT ORG13_ConsentType_ConsentTypeName_UN UNIQUE (ConsentTypeName);

ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES ORG13_CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES ORG13_CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_ConsentTextVersion_FK FOREIGN KEY (ConsentTextVersionKey) REFERENCES ORG13_ConsentTextVersion (ConsentTextVersionKey);
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_Application_FK FOREIGN KEY (ApplicationKey) REFERENCES ORG13_Application (ApplicationKey);
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_ApplicationStatus_FK FOREIGN KEY (ApplicationStatusKey) REFERENCES ORG13_ApplicationStatus (ApplicationStatusKey);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_ConsentType_FK FOREIGN KEY (ConsentTypeKey) REFERENCES ORG13_ConsentType (ConsentTypeKey);

-- Organizm 14: Zgłoszenie wyniku rekrutacji
-- Relacja kandydata o tym, co stało się po aplikacji, i przypomnienia, które go o to pytają.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG14_ReportOutcome (
    ReportOutcomeKey   NUMBER(2)     NOT NULL,
    ReportOutcomeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG14_RecruitmentReport (
    RecruitmentReportKey   NUMBER(11)  NOT NULL,
    CandidatePseudonymKey  NUMBER(10)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    ReportOutcomeKey       NUMBER(2)   NOT NULL,
    RecruitmentStageKey    NUMBER(2)   NOT NULL,
    ReportChannelKey       NUMBER(2)   NOT NULL,
    ReminderKey            NUMBER(11),
    ReportedAt             TIMESTAMP   NOT NULL
);

CREATE TABLE ORG14_Reminder (
    ReminderKey        NUMBER(11)  NOT NULL,
    ApplicationKey     NUMBER(12)  NOT NULL,
    ReminderStatusKey  NUMBER(2)   NOT NULL,
    ReminderNumber     NUMBER(1)   NOT NULL,
    SentAt             TIMESTAMP   NOT NULL
);

CREATE TABLE ORG14_RecruitmentStage (
    RecruitmentStageKey   NUMBER(2)     NOT NULL,
    RecruitmentStageName  VARCHAR2(40)  NOT NULL,
    StageRank             NUMBER(2)     NOT NULL
);

CREATE TABLE ORG14_ReportChannel (
    ReportChannelKey   NUMBER(2)     NOT NULL,
    ReportChannelName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG14_ReminderStatus (
    ReminderStatusKey   NUMBER(2)     NOT NULL,
    ReminderStatusName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG14_ReportOutcome IS 'Wynik rekrutacji według kandydata.';
COMMENT ON COLUMN ORG14_ReportOutcome.ReportOutcomeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_ReportOutcome.ReportOutcomeName IS 'Nazwa wyniku';

COMMENT ON TABLE ORG14_RecruitmentReport IS 'Zgłoszenie wyniku rekrutacji – tylko dopisujemy, nie poprawiamy.';
COMMENT ON COLUMN ORG14_RecruitmentReport.RecruitmentReportKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_RecruitmentReport.CandidatePseudonymKey IS 'Kto zgłasza';
COMMENT ON COLUMN ORG14_RecruitmentReport.JobPostingKey IS 'Którego ogłoszenia dotyczy';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReportOutcomeKey IS 'Wynik';
COMMENT ON COLUMN ORG14_RecruitmentReport.RecruitmentStageKey IS 'Na którym etapie się skończyło';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReportChannelKey IS 'Jak zgłoszono';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReminderKey IS 'Przypomnienie, po którym przyszło zgłoszenie';
COMMENT ON COLUMN ORG14_RecruitmentReport.ReportedAt IS 'Kiedy zgłoszono';

COMMENT ON TABLE ORG14_Reminder IS 'Przypomnienie wysłane kandydatowi przez platformę na naszą prośbę.';
COMMENT ON COLUMN ORG14_Reminder.ReminderKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_Reminder.ApplicationKey IS 'Aplikacja, o którą pytamy';
COMMENT ON COLUMN ORG14_Reminder.ReminderStatusKey IS 'Co się stało z przypomnieniem';
COMMENT ON COLUMN ORG14_Reminder.ReminderNumber IS 'Które to przypomnienie (1, 2…)';
COMMENT ON COLUMN ORG14_Reminder.SentAt IS 'Kiedy zlecono';

COMMENT ON TABLE ORG14_RecruitmentStage IS 'Etap rekrutacji.';
COMMENT ON COLUMN ORG14_RecruitmentStage.RecruitmentStageKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_RecruitmentStage.RecruitmentStageName IS 'Nazwa etapu';
COMMENT ON COLUMN ORG14_RecruitmentStage.StageRank IS 'Kolejność etapów';

COMMENT ON TABLE ORG14_ReportChannel IS 'Jak przyszło zgłoszenie.';
COMMENT ON COLUMN ORG14_ReportChannel.ReportChannelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_ReportChannel.ReportChannelName IS 'Nazwa kanału';

COMMENT ON TABLE ORG14_ReminderStatus IS 'Los przypomnienia.';
COMMENT ON COLUMN ORG14_ReminderStatus.ReminderStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG14_ReminderStatus.ReminderStatusName IS 'Nazwa stanu przypomnienia';

ALTER TABLE ORG14_ReportOutcome ADD CONSTRAINT ORG14_ReportOutcome_PK PRIMARY KEY (ReportOutcomeKey);
ALTER TABLE ORG14_ReportOutcome ADD CONSTRAINT ORG14_ReportOutcome_ReportOutcomeName_UN UNIQUE (ReportOutcomeName);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_PK PRIMARY KEY (RecruitmentReportKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_PK PRIMARY KEY (ReminderKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_UN UNIQUE (ApplicationKey, ReminderNumber);
ALTER TABLE ORG14_RecruitmentStage ADD CONSTRAINT ORG14_RecruitmentStage_PK PRIMARY KEY (RecruitmentStageKey);
ALTER TABLE ORG14_RecruitmentStage ADD CONSTRAINT ORG14_RecruitmentStage_RecruitmentStageName_UN UNIQUE (RecruitmentStageName);
ALTER TABLE ORG14_ReportChannel ADD CONSTRAINT ORG14_ReportChannel_PK PRIMARY KEY (ReportChannelKey);
ALTER TABLE ORG14_ReportChannel ADD CONSTRAINT ORG14_ReportChannel_ReportChannelName_UN UNIQUE (ReportChannelName);
ALTER TABLE ORG14_ReminderStatus ADD CONSTRAINT ORG14_ReminderStatus_PK PRIMARY KEY (ReminderStatusKey);
ALTER TABLE ORG14_ReminderStatus ADD CONSTRAINT ORG14_ReminderStatus_ReminderStatusName_UN UNIQUE (ReminderStatusName);

ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_ReportOutcome_FK FOREIGN KEY (ReportOutcomeKey) REFERENCES ORG14_ReportOutcome (ReportOutcomeKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_RecruitmentStage_FK FOREIGN KEY (RecruitmentStageKey) REFERENCES ORG14_RecruitmentStage (RecruitmentStageKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_ReportChannel_FK FOREIGN KEY (ReportChannelKey) REFERENCES ORG14_ReportChannel (ReportChannelKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_Reminder_FK FOREIGN KEY (ReminderKey) REFERENCES ORG14_Reminder (ReminderKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_ReminderStatus_FK FOREIGN KEY (ReminderStatusKey) REFERENCES ORG14_ReminderStatus (ReminderStatusKey);

-- Organizm 15: Weryfikacja zgłoszenia
-- Niezależne sprawdzenia każdego zgłoszenia i ocena, czy liczy się do Trust Score.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG15_CheckType (
    CheckTypeKey   NUMBER(2)     NOT NULL,
    CheckTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG15_VerdictDecision (
    VerdictDecisionKey   NUMBER(2)     NOT NULL,
    VerdictDecisionName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG15_ReportCheck (
    ReportCheckKey        NUMBER(12)     NOT NULL,
    RecruitmentReportKey  NUMBER(11)     NOT NULL,
    CheckTypeKey          NUMBER(2)      NOT NULL,
    CheckResultKey        NUMBER(2)      NOT NULL,
    CheckedAt             TIMESTAMP      NOT NULL,
    CheckDetails          VARCHAR2(400)
);

CREATE TABLE ORG15_ReportVerdict (
    ReportVerdictKey      NUMBER(11)    NOT NULL,
    RecruitmentReportKey  NUMBER(11)    NOT NULL,
    VerdictDecisionKey    NUMBER(2)     NOT NULL,
    ReportWeight          NUMBER(3,2)   NOT NULL,
    RuleSetVersion        VARCHAR2(20)  NOT NULL,
    DecidedAt             TIMESTAMP     NOT NULL
);

CREATE TABLE ORG15_CheckResult (
    CheckResultKey   NUMBER(2)     NOT NULL,
    CheckResultName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG15_ReportDevice (
    ReportDeviceKey       NUMBER(11)  NOT NULL,
    RecruitmentReportKey  NUMBER(11)  NOT NULL,
    DeviceFingerprintKey  NUMBER(10)  NOT NULL
);

CREATE TABLE ORG15_DeviceFingerprint (
    DeviceFingerprintKey  NUMBER(10)    NOT NULL,
    FingerprintHash       VARCHAR2(64)  NOT NULL,
    FirstSeenAt           TIMESTAMP     NOT NULL,
    ExpiresAt             DATE          NOT NULL
);

COMMENT ON TABLE ORG15_CheckType IS 'Rodzaj sprawdzenia.';
COMMENT ON COLUMN ORG15_CheckType.CheckTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_CheckType.CheckTypeName IS 'Nazwa sprawdzenia';

COMMENT ON TABLE ORG15_VerdictDecision IS 'Decyzja o zgłoszeniu.';
COMMENT ON COLUMN ORG15_VerdictDecision.VerdictDecisionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_VerdictDecision.VerdictDecisionName IS 'Nazwa decyzji';

COMMENT ON TABLE ORG15_ReportCheck IS 'Wynik jednego sprawdzenia jednego zgłoszenia.';
COMMENT ON COLUMN ORG15_ReportCheck.ReportCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_ReportCheck.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ORG15_ReportCheck.CheckTypeKey IS 'Rodzaj sprawdzenia';
COMMENT ON COLUMN ORG15_ReportCheck.CheckResultKey IS 'Wynik';
COMMENT ON COLUMN ORG15_ReportCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN ORG15_ReportCheck.CheckDetails IS 'Szczegóły, np. „aplikacja 34 dni temu”';

COMMENT ON TABLE ORG15_ReportVerdict IS 'Ocena zgłoszenia – każda ponowna ocena to nowy wiersz.';
COMMENT ON COLUMN ORG15_ReportVerdict.ReportVerdictKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_ReportVerdict.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ORG15_ReportVerdict.VerdictDecisionKey IS 'Decyzja';
COMMENT ON COLUMN ORG15_ReportVerdict.ReportWeight IS 'Waga od 0 do 1';
COMMENT ON COLUMN ORG15_ReportVerdict.RuleSetVersion IS 'Wersja reguł oceny';
COMMENT ON COLUMN ORG15_ReportVerdict.DecidedAt IS 'Kiedy oceniono';

COMMENT ON TABLE ORG15_CheckResult IS 'Wynik sprawdzenia.';
COMMENT ON COLUMN ORG15_CheckResult.CheckResultKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_CheckResult.CheckResultName IS 'Nazwa wyniku';

COMMENT ON TABLE ORG15_ReportDevice IS 'Urządzenie, z którego wysłano zgłoszenie – tabela łącząca.';
COMMENT ON COLUMN ORG15_ReportDevice.ReportDeviceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_ReportDevice.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ORG15_ReportDevice.DeviceFingerprintKey IS 'Urządzenie';

COMMENT ON TABLE ORG15_DeviceFingerprint IS 'Urządzenie zapisane tylko jako skrót cech.';
COMMENT ON COLUMN ORG15_DeviceFingerprint.DeviceFingerprintKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_DeviceFingerprint.FingerprintHash IS 'Skrót cech urządzenia (bez samych cech)';
COMMENT ON COLUMN ORG15_DeviceFingerprint.FirstSeenAt IS 'Kiedy pierwszy raz';
COMMENT ON COLUMN ORG15_DeviceFingerprint.ExpiresAt IS 'Kiedy usunąć – dane osobowe trzymamy krótko';

ALTER TABLE ORG15_CheckType ADD CONSTRAINT ORG15_CheckType_PK PRIMARY KEY (CheckTypeKey);
ALTER TABLE ORG15_CheckType ADD CONSTRAINT ORG15_CheckType_CheckTypeName_UN UNIQUE (CheckTypeName);
ALTER TABLE ORG15_VerdictDecision ADD CONSTRAINT ORG15_VerdictDecision_PK PRIMARY KEY (VerdictDecisionKey);
ALTER TABLE ORG15_VerdictDecision ADD CONSTRAINT ORG15_VerdictDecision_VerdictDecisionName_UN UNIQUE (VerdictDecisionName);
ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_PK PRIMARY KEY (ReportCheckKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_PK PRIMARY KEY (ReportVerdictKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_CK1 CHECK (ReportWeight BETWEEN 0 AND 1);
ALTER TABLE ORG15_CheckResult ADD CONSTRAINT ORG15_CheckResult_PK PRIMARY KEY (CheckResultKey);
ALTER TABLE ORG15_CheckResult ADD CONSTRAINT ORG15_CheckResult_CheckResultName_UN UNIQUE (CheckResultName);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_PK PRIMARY KEY (ReportDeviceKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_RecruitmentReportKey_UN UNIQUE (RecruitmentReportKey);
ALTER TABLE ORG15_DeviceFingerprint ADD CONSTRAINT ORG15_DeviceFingerprint_PK PRIMARY KEY (DeviceFingerprintKey);
ALTER TABLE ORG15_DeviceFingerprint ADD CONSTRAINT ORG15_DeviceFingerprint_FingerprintHash_UN UNIQUE (FingerprintHash);

ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_CheckType_FK FOREIGN KEY (CheckTypeKey) REFERENCES ORG15_CheckType (CheckTypeKey);
ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_CheckResult_FK FOREIGN KEY (CheckResultKey) REFERENCES ORG15_CheckResult (CheckResultKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_VerdictDecision_FK FOREIGN KEY (VerdictDecisionKey) REFERENCES ORG15_VerdictDecision (VerdictDecisionKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_DeviceFingerprint_FK FOREIGN KEY (DeviceFingerprintKey) REFERENCES ORG15_DeviceFingerprint (DeviceFingerprintKey);

-- Organizm 16: Wykrywanie nadużyć
-- Wzorce wielu podejrzanych zgłoszeń naraz – podejrzenie, które potwierdza albo odrzuca człowiek.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG16_AlertType (
    AlertTypeKey   NUMBER(2)     NOT NULL,
    AlertTypeName  VARCHAR2(50)  NOT NULL
);

CREATE TABLE ORG16_AlertStatus (
    AlertStatusKey   NUMBER(2)     NOT NULL,
    AlertStatusName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG16_AbuseAlert (
    AbuseAlertKey   NUMBER(9)  NOT NULL,
    EmployerKey     NUMBER(8)  NOT NULL,
    AlertTypeKey    NUMBER(2)  NOT NULL,
    AlertStatusKey  NUMBER(2)  NOT NULL,
    WindowStart     TIMESTAMP  NOT NULL,
    WindowEnd       TIMESTAMP  NOT NULL,
    DetectedAt      TIMESTAMP  NOT NULL,
    ReportCount     NUMBER(6)  NOT NULL
);

CREATE TABLE ORG16_AlertReport (
    AlertReportKey        NUMBER(11)  NOT NULL,
    AbuseAlertKey         NUMBER(9)   NOT NULL,
    RecruitmentReportKey  NUMBER(11)  NOT NULL
);

COMMENT ON TABLE ORG16_AlertType IS 'Rodzaj podejrzanego wzorca.';
COMMENT ON COLUMN ORG16_AlertType.AlertTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertType.AlertTypeName IS 'Nazwa wzorca';

COMMENT ON TABLE ORG16_AlertStatus IS 'Stan alertu.';
COMMENT ON COLUMN ORG16_AlertStatus.AlertStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertStatus.AlertStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG16_AbuseAlert IS 'Alert o podejrzanej fali zgłoszeń dotyczącej jednej firmy.';
COMMENT ON COLUMN ORG16_AbuseAlert.AbuseAlertKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AbuseAlert.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG16_AbuseAlert.AlertTypeKey IS 'Rodzaj wzorca';
COMMENT ON COLUMN ORG16_AbuseAlert.AlertStatusKey IS 'Stan';
COMMENT ON COLUMN ORG16_AbuseAlert.WindowStart IS 'Początek okresu fali';
COMMENT ON COLUMN ORG16_AbuseAlert.WindowEnd IS 'Koniec okresu fali';
COMMENT ON COLUMN ORG16_AbuseAlert.DetectedAt IS 'Kiedy wykryto';
COMMENT ON COLUMN ORG16_AbuseAlert.ReportCount IS 'Ile zgłoszeń w fali';

COMMENT ON TABLE ORG16_AlertReport IS 'Zgłoszenie objęte alertem – tabela łącząca.';
COMMENT ON COLUMN ORG16_AlertReport.AlertReportKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertReport.AbuseAlertKey IS 'Alert';
COMMENT ON COLUMN ORG16_AlertReport.RecruitmentReportKey IS 'Zgłoszenie';

ALTER TABLE ORG16_AlertType ADD CONSTRAINT ORG16_AlertType_PK PRIMARY KEY (AlertTypeKey);
ALTER TABLE ORG16_AlertType ADD CONSTRAINT ORG16_AlertType_AlertTypeName_UN UNIQUE (AlertTypeName);
ALTER TABLE ORG16_AlertStatus ADD CONSTRAINT ORG16_AlertStatus_PK PRIMARY KEY (AlertStatusKey);
ALTER TABLE ORG16_AlertStatus ADD CONSTRAINT ORG16_AlertStatus_AlertStatusName_UN UNIQUE (AlertStatusName);
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_PK PRIMARY KEY (AbuseAlertKey);
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_CK1 CHECK (WindowEnd >= WindowStart);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_PK PRIMARY KEY (AlertReportKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_UN UNIQUE (AbuseAlertKey, RecruitmentReportKey);

ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_AlertType_FK FOREIGN KEY (AlertTypeKey) REFERENCES ORG16_AlertType (AlertTypeKey);
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_AlertStatus_FK FOREIGN KEY (AlertStatusKey) REFERENCES ORG16_AlertStatus (AlertStatusKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_AbuseAlert_FK FOREIGN KEY (AbuseAlertKey) REFERENCES ORG16_AbuseAlert (AbuseAlertKey);

-- Organizm 17: Sygnały o firmie
-- Liczby opisujące zachowanie firmy, policzone na dany dzień – wejście do Trust Score.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG17_SignalGroup (
    SignalGroupKey   NUMBER(2)     NOT NULL,
    SignalGroupName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG17_SignalSnapshot (
    SignalSnapshotKey  NUMBER(10)  NOT NULL,
    EmployerKey        NUMBER(8)   NOT NULL,
    SnapshotDate       DATE        NOT NULL
);

CREATE TABLE ORG17_SignalValue (
    SignalValueKey      NUMBER(12)    NOT NULL,
    SignalSnapshotKey   NUMBER(10)    NOT NULL,
    SignalTypeKey       NUMBER(3)     NOT NULL,
    SignalNumericValue  NUMBER(12,4)  NOT NULL,
    BasedOnCount        NUMBER(7)
);

CREATE TABLE ORG17_SignalType (
    SignalTypeKey      NUMBER(3)      NOT NULL,
    SignalTypeName     VARCHAR2(80)   NOT NULL,
    SignalGroupKey     NUMBER(2)      NOT NULL,
    SignalUnit         VARCHAR2(20)   NOT NULL,
    HigherIsBetter     CHAR(1)        NOT NULL,
    SignalDescription  VARCHAR2(300)
);

COMMENT ON TABLE ORG17_SignalGroup IS 'Grupa sygnałów.';
COMMENT ON COLUMN ORG17_SignalGroup.SignalGroupKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalGroup.SignalGroupName IS 'Nazwa grupy';

COMMENT ON TABLE ORG17_SignalSnapshot IS 'Stan sygnałów jednej firmy na dany dzień.';
COMMENT ON COLUMN ORG17_SignalSnapshot.SignalSnapshotKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalSnapshot.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG17_SignalSnapshot.SnapshotDate IS 'Na jaki dzień';

COMMENT ON TABLE ORG17_SignalValue IS 'Wartość jednego sygnału w jednym stanie.';
COMMENT ON COLUMN ORG17_SignalValue.SignalValueKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalValue.SignalSnapshotKey IS 'Stan na dany dzień';
COMMENT ON COLUMN ORG17_SignalValue.SignalTypeKey IS 'Rodzaj sygnału';
COMMENT ON COLUMN ORG17_SignalValue.SignalNumericValue IS 'Wartość';
COMMENT ON COLUMN ORG17_SignalValue.BasedOnCount IS 'Na ilu danych opiera się wartość';

COMMENT ON TABLE ORG17_SignalType IS 'Rodzaj sygnału z jednostką i kierunkiem.';
COMMENT ON COLUMN ORG17_SignalType.SignalTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_SignalType.SignalTypeName IS 'Nazwa sygnału';
COMMENT ON COLUMN ORG17_SignalType.SignalGroupKey IS 'Grupa';
COMMENT ON COLUMN ORG17_SignalType.SignalUnit IS 'Jednostka, np. %, dni, liczba';
COMMENT ON COLUMN ORG17_SignalType.HigherIsBetter IS 'T = im więcej, tym lepiej dla firmy';
COMMENT ON COLUMN ORG17_SignalType.SignalDescription IS 'Jak liczymy';

ALTER TABLE ORG17_SignalGroup ADD CONSTRAINT ORG17_SignalGroup_PK PRIMARY KEY (SignalGroupKey);
ALTER TABLE ORG17_SignalGroup ADD CONSTRAINT ORG17_SignalGroup_SignalGroupName_UN UNIQUE (SignalGroupName);
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_PK PRIMARY KEY (SignalSnapshotKey);
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_UN UNIQUE (EmployerKey, SnapshotDate);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_PK PRIMARY KEY (SignalValueKey);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_UN UNIQUE (SignalSnapshotKey, SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_PK PRIMARY KEY (SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_SignalTypeName_UN UNIQUE (SignalTypeName);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_HigherIsBetter_CK CHECK (HigherIsBetter IN ('T', 'N'));

ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES ORG17_SignalSnapshot (SignalSnapshotKey);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_SignalGroup_FK FOREIGN KEY (SignalGroupKey) REFERENCES ORG17_SignalGroup (SignalGroupKey);

-- Organizm 18: Trust Score i publikacja
-- Wynik firmy policzony konkretną metodą, z pewnością i powodami – oraz to, co wolno pokazać kandydatowi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG18_ScoringMethodType (
    ScoringMethodTypeKey   NUMBER(2)     NOT NULL,
    ScoringMethodTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG18_ScoringMethod (
    ScoringMethodKey      NUMBER(4)     NOT NULL,
    ScoringMethodTypeKey  NUMBER(2)     NOT NULL,
    MethodVersion         VARCHAR2(20)  NOT NULL,
    ValidFrom             DATE          NOT NULL,
    ValidTo               DATE
);

CREATE TABLE ORG18_ScoringWeight (
    ScoringWeightKey  NUMBER(6)    NOT NULL,
    ScoringMethodKey  NUMBER(4)    NOT NULL,
    SignalTypeKey     NUMBER(3)    NOT NULL,
    WeightValue       NUMBER(5,3)  NOT NULL
);

CREATE TABLE ORG18_TrustScore (
    TrustScoreKey      NUMBER(11)   NOT NULL,
    SignalSnapshotKey  NUMBER(10)   NOT NULL,
    ScoringMethodKey   NUMBER(4)    NOT NULL,
    ScoreValue         NUMBER(3)    NOT NULL,
    ScoreConfidence    NUMBER(3,2)  NOT NULL,
    CalculatedAt       TIMESTAMP    NOT NULL
);

CREATE TABLE ORG18_ScoreReason (
    ScoreReasonKey  NUMBER(12)     NOT NULL,
    TrustScoreKey   NUMBER(11)     NOT NULL,
    SignalTypeKey   NUMBER(3)      NOT NULL,
    ReasonRank      NUMBER(1)      NOT NULL,
    ReasonText      VARCHAR2(300)  NOT NULL
);

CREATE TABLE ORG18_PublishedScore (
    PublishedScoreKey     NUMBER(10)  NOT NULL,
    TrustScoreKey         NUMBER(11)  NOT NULL,
    PublicationStatusKey  NUMBER(2)   NOT NULL,
    PublishedFrom         TIMESTAMP   NOT NULL,
    PublishedTo           TIMESTAMP
);

CREATE TABLE ORG18_PublicationStatus (
    PublicationStatusKey   NUMBER(2)     NOT NULL,
    PublicationStatusName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG18_ScoringMethodType IS 'Rodzaj metody liczenia wyniku.';
COMMENT ON COLUMN ORG18_ScoringMethodType.ScoringMethodTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringMethodType.ScoringMethodTypeName IS 'Nazwa rodzaju metody';

COMMENT ON TABLE ORG18_ScoringMethod IS 'Metoda liczenia wyniku w konkretnej wersji.';
COMMENT ON COLUMN ORG18_ScoringMethod.ScoringMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringMethod.ScoringMethodTypeKey IS 'Rodzaj metody';
COMMENT ON COLUMN ORG18_ScoringMethod.MethodVersion IS 'Wersja';
COMMENT ON COLUMN ORG18_ScoringMethod.ValidFrom IS 'Od kiedy używana';
COMMENT ON COLUMN ORG18_ScoringMethod.ValidTo IS 'Do kiedy (puste = obecna)';

COMMENT ON TABLE ORG18_ScoringWeight IS 'Waga sygnału w danej metodzie – tabela łącząca z wartością.';
COMMENT ON COLUMN ORG18_ScoringWeight.ScoringWeightKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringWeight.ScoringMethodKey IS 'Metoda';
COMMENT ON COLUMN ORG18_ScoringWeight.SignalTypeKey IS 'Sygnał';
COMMENT ON COLUMN ORG18_ScoringWeight.WeightValue IS 'Waga';

COMMENT ON TABLE ORG18_TrustScore IS 'Wynik roboczy – każde przeliczenie to nowy wiersz.';
COMMENT ON COLUMN ORG18_TrustScore.TrustScoreKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_TrustScore.SignalSnapshotKey IS 'Na jakich danych liczono';
COMMENT ON COLUMN ORG18_TrustScore.ScoringMethodKey IS 'Jaką metodą';
COMMENT ON COLUMN ORG18_TrustScore.ScoreValue IS 'Wynik od 0 do 100';
COMMENT ON COLUMN ORG18_TrustScore.ScoreConfidence IS 'Pewność od 0 do 1';
COMMENT ON COLUMN ORG18_TrustScore.CalculatedAt IS 'Kiedy policzono';

COMMENT ON TABLE ORG18_ScoreReason IS 'Powód wyniku pokazywany kandydatowi i firmie.';
COMMENT ON COLUMN ORG18_ScoreReason.ScoreReasonKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoreReason.TrustScoreKey IS 'Wynik';
COMMENT ON COLUMN ORG18_ScoreReason.SignalTypeKey IS 'Którego sygnału dotyczy';
COMMENT ON COLUMN ORG18_ScoreReason.ReasonRank IS 'Kolejność ważności';
COMMENT ON COLUMN ORG18_ScoreReason.ReasonText IS 'Tekst, np. „to samo ogłoszenie 7 razy w 9 miesięcy”';

COMMENT ON TABLE ORG18_PublishedScore IS 'Wynik pokazany publicznie – osobno od wyniku roboczego.';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedScoreKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_PublishedScore.TrustScoreKey IS 'Który wynik pokazujemy';
COMMENT ON COLUMN ORG18_PublishedScore.PublicationStatusKey IS 'Stan publikacji';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedTo IS 'Do kiedy (puste = widoczny teraz)';

COMMENT ON TABLE ORG18_PublicationStatus IS 'Stan publikacji wyniku.';
COMMENT ON COLUMN ORG18_PublicationStatus.PublicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_PublicationStatus.PublicationStatusName IS 'Nazwa stanu publikacji';

ALTER TABLE ORG18_ScoringMethodType ADD CONSTRAINT ORG18_ScoringMethodType_PK PRIMARY KEY (ScoringMethodTypeKey);
ALTER TABLE ORG18_ScoringMethodType ADD CONSTRAINT ORG18_ScoringMethodType_ScoringMethodTypeName_UN UNIQUE (ScoringMethodTypeName);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_PK PRIMARY KEY (ScoringMethodKey);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_UN UNIQUE (ScoringMethodTypeKey, MethodVersion);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_PK PRIMARY KEY (ScoringWeightKey);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_UN UNIQUE (ScoringMethodKey, SignalTypeKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_PK PRIMARY KEY (TrustScoreKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_CK1 CHECK (ScoreValue BETWEEN 0 AND 100);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_CK2 CHECK (ScoreConfidence BETWEEN 0 AND 1);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_PK PRIMARY KEY (ScoreReasonKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_UN UNIQUE (TrustScoreKey, ReasonRank);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_PK PRIMARY KEY (PublishedScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_CK1 CHECK (PublishedTo IS NULL OR PublishedTo >= PublishedFrom);
ALTER TABLE ORG18_PublicationStatus ADD CONSTRAINT ORG18_PublicationStatus_PK PRIMARY KEY (PublicationStatusKey);
ALTER TABLE ORG18_PublicationStatus ADD CONSTRAINT ORG18_PublicationStatus_PublicationStatusName_UN UNIQUE (PublicationStatusName);

ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_ScoringMethodType_FK FOREIGN KEY (ScoringMethodTypeKey) REFERENCES ORG18_ScoringMethodType (ScoringMethodTypeKey);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ORG18_ScoringMethod (ScoringMethodKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ORG18_ScoringMethod (ScoringMethodKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES ORG18_TrustScore (TrustScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES ORG18_TrustScore (TrustScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_PublicationStatus_FK FOREIGN KEY (PublicationStatusKey) REFERENCES ORG18_PublicationStatus (PublicationStatusKey);

-- Połączenia między organizmami: klucze obce do tabel z innych organizmów.
-- Uruchom po plikach 01–18. Wygenerowane z narzedzia/organizmy.py.

-- organizm 2: API platformy
ALTER TABLE ORG02_PlatformAPI ADD CONSTRAINT ORG02_PlatformAPI_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);

-- organizm 3: Endpointy i zwracane dane
ALTER TABLE ORG03_APIEndpoint ADD CONSTRAINT ORG03_APIEndpoint_APIVersion_FK FOREIGN KEY (APIVersionKey) REFERENCES ORG02_APIVersion (APIVersionKey);
ALTER TABLE ORG03_EndpointResponse ADD CONSTRAINT ORG03_EndpointResponse_DataFormat_FK FOREIGN KEY (DataFormatKey) REFERENCES ORG02_DataFormat (DataFormatKey);

-- organizm 4: Odbiór danych z platformy
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_APIEndpoint_FK FOREIGN KEY (APIEndpointKey) REFERENCES ORG03_APIEndpoint (APIEndpointKey);

-- organizm 5: Konto firmy na platformie
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES ORG04_RawRecord (RawRecordKey);

-- organizm 6: Firma w rejestrach publicznych
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);

-- organizm 7: Powiązanie kont z firmą
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_AgencyEmployerKey_FK FOREIGN KEY (AgencyEmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_ClientEmployerKey_FK FOREIGN KEY (ClientEmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 8: Ogłoszenie i miejsce pracy
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES ORG04_RawRecord (RawRecordKey);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);

-- organizm 9: Warunki zatrudnienia
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG09_PostingBenefit ADD CONSTRAINT ORG09_PostingBenefit_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);

-- organizm 10: Wymagania i obowiązki
ALTER TABLE ORG10_PostingResponsibility ADD CONSTRAINT ORG10_PostingResponsibility_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);

-- organizm 11: Historia i treść ogłoszenia
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG11_BoilerplatePattern ADD CONSTRAINT ORG11_BoilerplatePattern_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 12: Podobne ogłoszenia i rodziny
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_FirstJobPostingKey_FK FOREIGN KEY (FirstJobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SecondJobPostingKey_FK FOREIGN KEY (SecondJobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 13: Kandydat, aplikacje i zgody
ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);

-- organizm 14: Zgłoszenie wyniku rekrutacji
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_CandidatePseudonym_FK FOREIGN KEY (CandidatePseudonymKey) REFERENCES ORG13_CandidatePseudonym (CandidatePseudonymKey);
ALTER TABLE ORG14_RecruitmentReport ADD CONSTRAINT ORG14_RecruitmentReport_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_Application_FK FOREIGN KEY (ApplicationKey) REFERENCES ORG13_Application (ApplicationKey);

-- organizm 15: Weryfikacja zgłoszenia
ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);

-- organizm 16: Wykrywanie nadużyć
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);

-- organizm 17: Sygnały o firmie
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 18: Trust Score i publikacja
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES ORG17_SignalSnapshot (SignalSnapshotKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
