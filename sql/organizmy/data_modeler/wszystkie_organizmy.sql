-- Cały model naraz: wszystkie organizmy i klucze obce między nimi – do Data Modeler.

-- Organizm 1: Źródło danych: platforma, API i endpointy
-- Skąd i jak przychodzą dane: platforma, jej kanały API, wersje i endpointy – aż do pojedynczego pola w odpowiedzi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG01_PlatformType (
    PlatformTypeKey   NUMBER(2)     NOT NULL,
    PlatformTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG01_PlatformClassification (
    PlatformClassificationKey  NUMBER(5)  NOT NULL,
    SourcePlatformKey          NUMBER(4)  NOT NULL,
    PlatformTypeKey            NUMBER(2)  NOT NULL,
    IsMainType                 NUMBER(1)  NOT NULL
);

CREATE TABLE ORG01_SourcePlatform (
    SourcePlatformKey   NUMBER(4)      NOT NULL,
    SourcePlatformName  VARCHAR2(50)   NOT NULL,
    MainHomePage        VARCHAR2(100)  NOT NULL,
    AddedDate           DATE           NOT NULL
);

CREATE TABLE ORG01_PlatformDomain (
    PlatformDomainKey  NUMBER(5)      NOT NULL,
    SourcePlatformKey  NUMBER(4)      NOT NULL,
    DomainName         VARCHAR2(100)  NOT NULL,
    IsMainDomain       NUMBER(1)      NOT NULL,
    ValidFrom          DATE           NOT NULL,
    ValidTo            DATE,
    IsCurrent          NUMBER(1)      NOT NULL
);

CREATE TABLE ORG01_PlatformMarket (
    PlatformMarketKey  NUMBER(5)  NOT NULL,
    SourcePlatformKey  NUMBER(4)  NOT NULL,
    CountryKey         NUMBER(3)  NOT NULL,
    ValidFrom          DATE,
    ValidTo            DATE,
    IsCurrent          NUMBER(1)  NOT NULL
);

CREATE TABLE ORG01_PartnerAgreement (
    PartnerAgreementKey         NUMBER(4)  NOT NULL,
    SourcePlatformKey           NUMBER(4)  NOT NULL,
    AgreementStatusKey          NUMBER(2)  NOT NULL,
    SignedDate                  DATE,
    ValidFrom                   DATE       NOT NULL,
    ValidTo                     DATE,
    IsCurrent                   NUMBER(1)  NOT NULL,
    HasDataProcessingAgreement  NUMBER(1)  NOT NULL
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

CREATE TABLE ORG01_APIType (
    APITypeKey   NUMBER(2)     NOT NULL,
    APITypeName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG01_DataFormat (
    DataFormatKey   NUMBER(2)     NOT NULL,
    DataFormatName  VARCHAR2(15)  NOT NULL,
    MimeType        VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG01_AuthMethod (
    AuthMethodKey   NUMBER(2)     NOT NULL,
    AuthMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG01_PlatformAPI (
    PlatformAPIKey     NUMBER(5)      NOT NULL,
    SourcePlatformKey  NUMBER(4)      NOT NULL,
    APITypeKey         NUMBER(2)      NOT NULL,
    DataFormatKey      NUMBER(2)      NOT NULL,
    AuthMethodKey      NUMBER(2)      NOT NULL,
    APIDirectionKey    NUMBER(1)      NOT NULL,
    PlatformAPIName    VARCHAR2(60)   NOT NULL,
    DocumentationURL   VARCHAR2(200)
);

CREATE TABLE ORG01_APIDirection (
    APIDirectionKey   NUMBER(1)     NOT NULL,
    APIDirectionName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG01_APIVersion (
    APIVersionKey   NUMBER(5)     NOT NULL,
    PlatformAPIKey  NUMBER(5)     NOT NULL,
    VersionLabel    VARCHAR2(10)  NOT NULL,
    ReleaseDate     DATE          NOT NULL,
    RetirementDate  DATE,
    IsInUse         NUMBER(1)     NOT NULL
);

CREATE TABLE ORG01_EnvironmentType (
    EnvironmentTypeKey   NUMBER(1)     NOT NULL,
    EnvironmentTypeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG01_APIEnvironment (
    APIEnvironmentKey      NUMBER(5)      NOT NULL,
    APIVersionKey          NUMBER(5)      NOT NULL,
    EnvironmentTypeKey     NUMBER(1)      NOT NULL,
    BaseURL                VARCHAR2(200)  NOT NULL,
    RequestLimitPerMinute  NUMBER(6)
);

CREATE TABLE ORG01_HTTPMethod (
    HTTPMethodKey   NUMBER(2)     NOT NULL,
    HTTPMethodName  VARCHAR2(10)  NOT NULL
);

CREATE TABLE ORG01_DataSubject (
    DataSubjectKey   NUMBER(2)     NOT NULL,
    DataSubjectName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG01_APIEndpoint (
    APIEndpointKey       NUMBER(6)      NOT NULL,
    APIVersionKey        NUMBER(5)      NOT NULL,
    HTTPMethodKey        NUMBER(2)      NOT NULL,
    DataSubjectKey       NUMBER(2)      NOT NULL,
    EndpointPath         VARCHAR2(200)  NOT NULL,
    IsPaginated          NUMBER(1)      NOT NULL,
    EndpointDescription  VARCHAR2(300)
);

CREATE TABLE ORG01_EndpointResponse (
    EndpointResponseKey  NUMBER(7)      NOT NULL,
    APIEndpointKey       NUMBER(6)      NOT NULL,
    HTTPStatusCode       CHAR(3)        NOT NULL,
    DataFormatKey        NUMBER(2)      NOT NULL,
    IsErrorResponse      NUMBER(1)      NOT NULL,
    ResponseDescription  VARCHAR2(200)
);

CREATE TABLE ORG01_FieldDataType (
    FieldDataTypeKey   NUMBER(2)     NOT NULL,
    FieldDataTypeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG01_EndpointData (
    EndpointDataKey        NUMBER(8)      NOT NULL,
    EndpointResponseKey    NUMBER(7)      NOT NULL,
    ParentEndpointDataKey  NUMBER(8),
    DataName               VARCHAR2(50)   NOT NULL,
    DataPath               VARCHAR2(200)  NOT NULL,
    FieldDataTypeKey       NUMBER(2)      NOT NULL,
    IsRequired             NUMBER(1)      NOT NULL,
    ExampleValue           VARCHAR2(200)
);

CREATE TABLE ORG01_CanonicalField (
    CanonicalFieldKey          NUMBER(4)      NOT NULL,
    CanonicalFieldName         VARCHAR2(60)   NOT NULL,
    DataSubjectKey             NUMBER(2)      NOT NULL,
    CanonicalFieldDescription  VARCHAR2(300)
);

CREATE TABLE ORG01_FieldMapping (
    FieldMappingKey     NUMBER(8)      NOT NULL,
    EndpointDataKey     NUMBER(8)      NOT NULL,
    CanonicalFieldKey   NUMBER(4)      NOT NULL,
    TransformationRule  VARCHAR2(300)
);

COMMENT ON TABLE ORG01_PlatformType IS 'Rodzaj platformy – czym w szerszym kontekście jest źródło ofert.';
COMMENT ON COLUMN ORG01_PlatformType.PlatformTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformType.PlatformTypeName IS 'Nazwa rodzaju platformy';

COMMENT ON TABLE ORG01_PlatformClassification IS 'Rodzaj platformy – jedna platforma bywa kilku rodzajów naraz; tabela łącząca platformy z rodzajami.';
COMMENT ON COLUMN ORG01_PlatformClassification.PlatformClassificationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformClassification.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PlatformClassification.PlatformTypeKey IS 'Rodzaj';
COMMENT ON COLUMN ORG01_PlatformClassification.IsMainType IS '1 = rodzaj główny, 0 = dodatkowy';

COMMENT ON TABLE ORG01_SourcePlatform IS 'Platforma, z której pochodzą dane, np. pracuj.pl albo OLX – ta sama tabela co na schemacie z zajęć.';
COMMENT ON COLUMN ORG01_SourcePlatform.SourcePlatformKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_SourcePlatform.SourcePlatformName IS 'Nazwa platformy, np. pracuj.pl';
COMMENT ON COLUMN ORG01_SourcePlatform.MainHomePage IS 'Adres strony głównej';
COMMENT ON COLUMN ORG01_SourcePlatform.AddedDate IS 'Kiedy dodaliśmy platformę jako źródło';

COMMENT ON TABLE ORG01_PlatformDomain IS 'Adres, pod którym działa platforma – z historią: adres może przestać działać albo przejść do innej platformy.';
COMMENT ON COLUMN ORG01_PlatformDomain.PlatformDomainKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformDomain.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PlatformDomain.DomainName IS 'Domena, np. it.pracuj.pl';
COMMENT ON COLUMN ORG01_PlatformDomain.IsMainDomain IS '1 = główny adres platformy';
COMMENT ON COLUMN ORG01_PlatformDomain.ValidFrom IS 'Od kiedy adres należy do platformy';
COMMENT ON COLUMN ORG01_PlatformDomain.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG01_PlatformDomain.IsCurrent IS '1 = adres aktualny, 0 = już nie';

COMMENT ON TABLE ORG01_PlatformMarket IS 'Kraj, w którym platforma publikuje oferty – przypisanie w czasie: platforma wchodzi do kraju i z niego wychodzi.';
COMMENT ON COLUMN ORG01_PlatformMarket.PlatformMarketKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformMarket.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PlatformMarket.CountryKey IS 'Kraj';
COMMENT ON COLUMN ORG01_PlatformMarket.ValidFrom IS 'Od kiedy platforma działa w tym kraju (puste = nie wiemy)';
COMMENT ON COLUMN ORG01_PlatformMarket.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG01_PlatformMarket.IsCurrent IS '1 = platforma działa tu teraz';

COMMENT ON TABLE ORG01_PartnerAgreement IS 'Etap umowy o współpracy z platformą. Każdy etap to nowy wiersz, aktualny jest jeden.';
COMMENT ON COLUMN ORG01_PartnerAgreement.PartnerAgreementKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PartnerAgreement.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG01_PartnerAgreement.AgreementStatusKey IS 'Etap umowy';
COMMENT ON COLUMN ORG01_PartnerAgreement.SignedDate IS 'Data podpisania';
COMMENT ON COLUMN ORG01_PartnerAgreement.ValidFrom IS 'Od kiedy obowiązuje';
COMMENT ON COLUMN ORG01_PartnerAgreement.ValidTo IS 'Do kiedy obowiązuje (puste = bez końca)';
COMMENT ON COLUMN ORG01_PartnerAgreement.IsCurrent IS '1 = etap aktualny';
COMMENT ON COLUMN ORG01_PartnerAgreement.HasDataProcessingAgreement IS '1 = podpisano umowę powierzenia danych osobowych (RODO)';

COMMENT ON TABLE ORG01_AgreementStatus IS 'Etap umowy z platformą.';
COMMENT ON COLUMN ORG01_AgreementStatus.AgreementStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_AgreementStatus.AgreementStatusName IS 'Nazwa etapu umowy';

COMMENT ON TABLE ORG01_Country IS 'Kraj – słownik używany też w organizmach 6 i 8.';
COMMENT ON COLUMN ORG01_Country.CountryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_Country.CountryCode IS 'Kod kraju ISO 3166, np. PL';
COMMENT ON COLUMN ORG01_Country.CountryName IS 'Nazwa kraju';

COMMENT ON TABLE ORG01_APIType IS 'Rodzaj API – jak na schemacie z zajęć.';
COMMENT ON COLUMN ORG01_APIType.APITypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_APIType.APITypeName IS 'Nazwa rodzaju API';

COMMENT ON TABLE ORG01_DataFormat IS 'Format danych – jak na schemacie z zajęć, z typem MIME.';
COMMENT ON COLUMN ORG01_DataFormat.DataFormatKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_DataFormat.DataFormatName IS 'Nazwa formatu';
COMMENT ON COLUMN ORG01_DataFormat.MimeType IS 'Typ MIME, np. application/json';

COMMENT ON TABLE ORG01_AuthMethod IS 'Sposób uwierzytelnienia przy połączeniu z API.';
COMMENT ON COLUMN ORG01_AuthMethod.AuthMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_AuthMethod.AuthMethodName IS 'Nazwa sposobu uwierzytelnienia';

COMMENT ON TABLE ORG01_PlatformAPI IS 'Kanał wymiany danych z jedną platformą – tabela ze schematu z zajęć, rozszerzona.';
COMMENT ON COLUMN ORG01_PlatformAPI.PlatformAPIKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_PlatformAPI.SourcePlatformKey IS 'Platforma, do której należy API';
COMMENT ON COLUMN ORG01_PlatformAPI.APITypeKey IS 'Rodzaj API';
COMMENT ON COLUMN ORG01_PlatformAPI.DataFormatKey IS 'Format domyślny';
COMMENT ON COLUMN ORG01_PlatformAPI.AuthMethodKey IS 'Jak się uwierzytelniamy';
COMMENT ON COLUMN ORG01_PlatformAPI.APIDirectionKey IS 'Kto zaczyna przesyłanie danych';
COMMENT ON COLUMN ORG01_PlatformAPI.PlatformAPIName IS 'Nazwa API, np. „Partner API”';
COMMENT ON COLUMN ORG01_PlatformAPI.DocumentationURL IS 'Adres dokumentacji API';

COMMENT ON TABLE ORG01_APIDirection IS 'Kierunek przesyłania danych.';
COMMENT ON COLUMN ORG01_APIDirection.APIDirectionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_APIDirection.APIDirectionName IS 'Nazwa kierunku';

COMMENT ON TABLE ORG01_APIVersion IS 'Wersja API. Endpointy różnią się między wersjami, a stare wersje platforma wyłącza.';
COMMENT ON COLUMN ORG01_APIVersion.APIVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_APIVersion.PlatformAPIKey IS 'API, którego to wersja';
COMMENT ON COLUMN ORG01_APIVersion.VersionLabel IS 'Oznaczenie wersji, np. v2';
COMMENT ON COLUMN ORG01_APIVersion.ReleaseDate IS 'Kiedy wersja weszła';
COMMENT ON COLUMN ORG01_APIVersion.RetirementDate IS 'Kiedy platforma wyłączy tę wersję';
COMMENT ON COLUMN ORG01_APIVersion.IsInUse IS '1 = z tej wersji korzysta teraz nasz program';

COMMENT ON TABLE ORG01_EnvironmentType IS 'Rodzaj środowiska API.';
COMMENT ON COLUMN ORG01_EnvironmentType.EnvironmentTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_EnvironmentType.EnvironmentTypeName IS 'Nazwa środowiska';

COMMENT ON TABLE ORG01_APIEnvironment IS 'Środowisko danej wersji API z własnym adresem i limitem zapytań.';
COMMENT ON COLUMN ORG01_APIEnvironment.APIEnvironmentKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_APIEnvironment.APIVersionKey IS 'Wersja API';
COMMENT ON COLUMN ORG01_APIEnvironment.EnvironmentTypeKey IS 'Rodzaj środowiska';
COMMENT ON COLUMN ORG01_APIEnvironment.BaseURL IS 'Adres bazowy, np. https://api.platforma.example/v2';
COMMENT ON COLUMN ORG01_APIEnvironment.RequestLimitPerMinute IS 'Ile zapytań na minutę pozwala platforma';

COMMENT ON TABLE ORG01_HTTPMethod IS 'Metoda HTTP endpointu.';
COMMENT ON COLUMN ORG01_HTTPMethod.HTTPMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_HTTPMethod.HTTPMethodName IS 'Nazwa metody';

COMMENT ON TABLE ORG01_DataSubject IS 'Czego dotyczą dane z endpointu – łączy endpointy z dalszymi organizmami.';
COMMENT ON COLUMN ORG01_DataSubject.DataSubjectKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_DataSubject.DataSubjectName IS 'Nazwa rodzaju danych';

COMMENT ON TABLE ORG01_APIEndpoint IS 'Jedno zapytanie w danej wersji API.';
COMMENT ON COLUMN ORG01_APIEndpoint.APIEndpointKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_APIEndpoint.APIVersionKey IS 'Wersja API';
COMMENT ON COLUMN ORG01_APIEndpoint.HTTPMethodKey IS 'Metoda HTTP';
COMMENT ON COLUMN ORG01_APIEndpoint.DataSubjectKey IS 'Czego dotyczą zwracane dane';
COMMENT ON COLUMN ORG01_APIEndpoint.EndpointPath IS 'Ścieżka, np. /v2/jobs';
COMMENT ON COLUMN ORG01_APIEndpoint.IsPaginated IS '1 = wyniki są dzielone na strony';
COMMENT ON COLUMN ORG01_APIEndpoint.EndpointDescription IS 'Co robi endpoint';

COMMENT ON TABLE ORG01_EndpointResponse IS 'Jedna możliwa odpowiedź endpointu: kod HTTP i format.';
COMMENT ON COLUMN ORG01_EndpointResponse.EndpointResponseKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_EndpointResponse.APIEndpointKey IS 'Endpoint';
COMMENT ON COLUMN ORG01_EndpointResponse.HTTPStatusCode IS 'Kod odpowiedzi HTTP, np. 200, 404, 429 – tekst, bo to kod, a nie liczba';
COMMENT ON COLUMN ORG01_EndpointResponse.DataFormatKey IS 'Format tej odpowiedzi';
COMMENT ON COLUMN ORG01_EndpointResponse.IsErrorResponse IS '1 = odpowiedź z błędem';
COMMENT ON COLUMN ORG01_EndpointResponse.ResponseDescription IS 'Kiedy pojawia się ta odpowiedź';

COMMENT ON TABLE ORG01_FieldDataType IS 'Typ danych pola w odpowiedzi.';
COMMENT ON COLUMN ORG01_FieldDataType.FieldDataTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_FieldDataType.FieldDataTypeName IS 'Nazwa typu';

COMMENT ON TABLE ORG01_EndpointData IS 'Jedno pole w odpowiedzi endpointu – odpowiednik PlatformAPIData ze schematu z zajęć.';
COMMENT ON COLUMN ORG01_EndpointData.EndpointDataKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_EndpointData.EndpointResponseKey IS 'Odpowiedź, w której jest pole';
COMMENT ON COLUMN ORG01_EndpointData.ParentEndpointDataKey IS 'Pole nadrzędne, gdy pole jest zagnieżdżone';
COMMENT ON COLUMN ORG01_EndpointData.DataName IS 'Nazwa pola u platformy, np. salary_from';
COMMENT ON COLUMN ORG01_EndpointData.DataPath IS 'Pełna ścieżka pola, np. salary.from';
COMMENT ON COLUMN ORG01_EndpointData.FieldDataTypeKey IS 'Typ danych pola';
COMMENT ON COLUMN ORG01_EndpointData.IsRequired IS '1 = platforma zawsze podaje to pole';
COMMENT ON COLUMN ORG01_EndpointData.ExampleValue IS 'Przykładowa wartość';

COMMENT ON TABLE ORG01_CanonicalField IS 'Nasza jedna nazwa danej, niezależna od platformy.';
COMMENT ON COLUMN ORG01_CanonicalField.CanonicalFieldKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_CanonicalField.CanonicalFieldName IS 'Nazwa, np. „Wynagrodzenie od”';
COMMENT ON COLUMN ORG01_CanonicalField.DataSubjectKey IS 'Czego dotyczy';
COMMENT ON COLUMN ORG01_CanonicalField.CanonicalFieldDescription IS 'Opis';

COMMENT ON TABLE ORG01_FieldMapping IS 'Przypisanie pola platformy do naszej nazwy, z regułą przeliczenia.';
COMMENT ON COLUMN ORG01_FieldMapping.FieldMappingKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG01_FieldMapping.EndpointDataKey IS 'Pole platformy';
COMMENT ON COLUMN ORG01_FieldMapping.CanonicalFieldKey IS 'Nasza nazwa';
COMMENT ON COLUMN ORG01_FieldMapping.TransformationRule IS 'Jak przeliczyć wartość, np. „grosze na złote: /100”';

ALTER TABLE ORG01_PlatformType ADD CONSTRAINT ORG01_PlatformType_PK PRIMARY KEY (PlatformTypeKey);
ALTER TABLE ORG01_PlatformType ADD CONSTRAINT ORG01_PlatformType_PlatformTypeName_UN UNIQUE (PlatformTypeName);
ALTER TABLE ORG01_PlatformClassification ADD CONSTRAINT ORG01_PlatformClassification_PK PRIMARY KEY (PlatformClassificationKey);
ALTER TABLE ORG01_PlatformClassification ADD CONSTRAINT ORG01_PlatformClassification_UN UNIQUE (SourcePlatformKey, PlatformTypeKey);
ALTER TABLE ORG01_PlatformClassification ADD CONSTRAINT ORG01_PlatformClassification_IsMainType_CK CHECK (IsMainType IN (0, 1));
ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_PK PRIMARY KEY (SourcePlatformKey);
ALTER TABLE ORG01_SourcePlatform ADD CONSTRAINT ORG01_SourcePlatform_SourcePlatformName_UN UNIQUE (SourcePlatformName);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_PK PRIMARY KEY (PlatformDomainKey);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_IsMainDomain_CK CHECK (IsMainDomain IN (0, 1));
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_PK PRIMARY KEY (PlatformMarketKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_PK PRIMARY KEY (PartnerAgreementKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_HasDataProcessingAgreement_CK CHECK (HasDataProcessingAgreement IN (0, 1));
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG01_AgreementStatus ADD CONSTRAINT ORG01_AgreementStatus_PK PRIMARY KEY (AgreementStatusKey);
ALTER TABLE ORG01_AgreementStatus ADD CONSTRAINT ORG01_AgreementStatus_AgreementStatusName_UN UNIQUE (AgreementStatusName);
ALTER TABLE ORG01_Country ADD CONSTRAINT ORG01_Country_PK PRIMARY KEY (CountryKey);
ALTER TABLE ORG01_Country ADD CONSTRAINT ORG01_Country_CountryCode_UN UNIQUE (CountryCode);
ALTER TABLE ORG01_Country ADD CONSTRAINT ORG01_Country_CK1 CHECK (REGEXP_LIKE(CountryCode, '^[A-Z]{2}$'));
ALTER TABLE ORG01_APIType ADD CONSTRAINT ORG01_APIType_PK PRIMARY KEY (APITypeKey);
ALTER TABLE ORG01_APIType ADD CONSTRAINT ORG01_APIType_APITypeName_UN UNIQUE (APITypeName);
ALTER TABLE ORG01_DataFormat ADD CONSTRAINT ORG01_DataFormat_PK PRIMARY KEY (DataFormatKey);
ALTER TABLE ORG01_DataFormat ADD CONSTRAINT ORG01_DataFormat_DataFormatName_UN UNIQUE (DataFormatName);
ALTER TABLE ORG01_DataFormat ADD CONSTRAINT ORG01_DataFormat_MimeType_UN UNIQUE (MimeType);
ALTER TABLE ORG01_AuthMethod ADD CONSTRAINT ORG01_AuthMethod_PK PRIMARY KEY (AuthMethodKey);
ALTER TABLE ORG01_AuthMethod ADD CONSTRAINT ORG01_AuthMethod_AuthMethodName_UN UNIQUE (AuthMethodName);
ALTER TABLE ORG01_PlatformAPI ADD CONSTRAINT ORG01_PlatformAPI_PK PRIMARY KEY (PlatformAPIKey);
ALTER TABLE ORG01_APIDirection ADD CONSTRAINT ORG01_APIDirection_PK PRIMARY KEY (APIDirectionKey);
ALTER TABLE ORG01_APIDirection ADD CONSTRAINT ORG01_APIDirection_APIDirectionName_UN UNIQUE (APIDirectionName);
ALTER TABLE ORG01_APIVersion ADD CONSTRAINT ORG01_APIVersion_PK PRIMARY KEY (APIVersionKey);
ALTER TABLE ORG01_APIVersion ADD CONSTRAINT ORG01_APIVersion_UN UNIQUE (PlatformAPIKey, VersionLabel);
ALTER TABLE ORG01_APIVersion ADD CONSTRAINT ORG01_APIVersion_IsInUse_CK CHECK (IsInUse IN (0, 1));
ALTER TABLE ORG01_APIVersion ADD CONSTRAINT ORG01_APIVersion_CK1 CHECK (RetirementDate IS NULL OR RetirementDate >= ReleaseDate);
ALTER TABLE ORG01_EnvironmentType ADD CONSTRAINT ORG01_EnvironmentType_PK PRIMARY KEY (EnvironmentTypeKey);
ALTER TABLE ORG01_EnvironmentType ADD CONSTRAINT ORG01_EnvironmentType_EnvironmentTypeName_UN UNIQUE (EnvironmentTypeName);
ALTER TABLE ORG01_APIEnvironment ADD CONSTRAINT ORG01_APIEnvironment_PK PRIMARY KEY (APIEnvironmentKey);
ALTER TABLE ORG01_APIEnvironment ADD CONSTRAINT ORG01_APIEnvironment_UN UNIQUE (APIVersionKey, EnvironmentTypeKey);
ALTER TABLE ORG01_HTTPMethod ADD CONSTRAINT ORG01_HTTPMethod_PK PRIMARY KEY (HTTPMethodKey);
ALTER TABLE ORG01_HTTPMethod ADD CONSTRAINT ORG01_HTTPMethod_HTTPMethodName_UN UNIQUE (HTTPMethodName);
ALTER TABLE ORG01_DataSubject ADD CONSTRAINT ORG01_DataSubject_PK PRIMARY KEY (DataSubjectKey);
ALTER TABLE ORG01_DataSubject ADD CONSTRAINT ORG01_DataSubject_DataSubjectName_UN UNIQUE (DataSubjectName);
ALTER TABLE ORG01_APIEndpoint ADD CONSTRAINT ORG01_APIEndpoint_PK PRIMARY KEY (APIEndpointKey);
ALTER TABLE ORG01_APIEndpoint ADD CONSTRAINT ORG01_APIEndpoint_UN UNIQUE (APIVersionKey, HTTPMethodKey, EndpointPath);
ALTER TABLE ORG01_APIEndpoint ADD CONSTRAINT ORG01_APIEndpoint_IsPaginated_CK CHECK (IsPaginated IN (0, 1));
ALTER TABLE ORG01_EndpointResponse ADD CONSTRAINT ORG01_EndpointResponse_PK PRIMARY KEY (EndpointResponseKey);
ALTER TABLE ORG01_EndpointResponse ADD CONSTRAINT ORG01_EndpointResponse_UN UNIQUE (APIEndpointKey, HTTPStatusCode, DataFormatKey);
ALTER TABLE ORG01_EndpointResponse ADD CONSTRAINT ORG01_EndpointResponse_IsErrorResponse_CK CHECK (IsErrorResponse IN (0, 1));
ALTER TABLE ORG01_EndpointResponse ADD CONSTRAINT ORG01_EndpointResponse_CK1 CHECK (REGEXP_LIKE(HTTPStatusCode, '^[1-5][0-9]{2}$'));
ALTER TABLE ORG01_FieldDataType ADD CONSTRAINT ORG01_FieldDataType_PK PRIMARY KEY (FieldDataTypeKey);
ALTER TABLE ORG01_FieldDataType ADD CONSTRAINT ORG01_FieldDataType_FieldDataTypeName_UN UNIQUE (FieldDataTypeName);
ALTER TABLE ORG01_EndpointData ADD CONSTRAINT ORG01_EndpointData_PK PRIMARY KEY (EndpointDataKey);
ALTER TABLE ORG01_EndpointData ADD CONSTRAINT ORG01_EndpointData_UN UNIQUE (EndpointResponseKey, DataPath);
ALTER TABLE ORG01_EndpointData ADD CONSTRAINT ORG01_EndpointData_IsRequired_CK CHECK (IsRequired IN (0, 1));
ALTER TABLE ORG01_CanonicalField ADD CONSTRAINT ORG01_CanonicalField_PK PRIMARY KEY (CanonicalFieldKey);
ALTER TABLE ORG01_CanonicalField ADD CONSTRAINT ORG01_CanonicalField_CanonicalFieldName_UN UNIQUE (CanonicalFieldName);
ALTER TABLE ORG01_FieldMapping ADD CONSTRAINT ORG01_FieldMapping_PK PRIMARY KEY (FieldMappingKey);
ALTER TABLE ORG01_FieldMapping ADD CONSTRAINT ORG01_FieldMapping_UN UNIQUE (EndpointDataKey, CanonicalFieldKey);

ALTER TABLE ORG01_PlatformClassification ADD CONSTRAINT ORG01_PlatformClassification_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformClassification ADD CONSTRAINT ORG01_PlatformClassification_PlatformType_FK FOREIGN KEY (PlatformTypeKey) REFERENCES ORG01_PlatformType (PlatformTypeKey);
ALTER TABLE ORG01_PlatformDomain ADD CONSTRAINT ORG01_PlatformDomain_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformMarket ADD CONSTRAINT ORG01_PlatformMarket_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PartnerAgreement ADD CONSTRAINT ORG01_PartnerAgreement_AgreementStatus_FK FOREIGN KEY (AgreementStatusKey) REFERENCES ORG01_AgreementStatus (AgreementStatusKey);
ALTER TABLE ORG01_PlatformAPI ADD CONSTRAINT ORG01_PlatformAPI_SourcePlatform_FK FOREIGN KEY (SourcePlatformKey) REFERENCES ORG01_SourcePlatform (SourcePlatformKey);
ALTER TABLE ORG01_PlatformAPI ADD CONSTRAINT ORG01_PlatformAPI_APIType_FK FOREIGN KEY (APITypeKey) REFERENCES ORG01_APIType (APITypeKey);
ALTER TABLE ORG01_PlatformAPI ADD CONSTRAINT ORG01_PlatformAPI_DataFormat_FK FOREIGN KEY (DataFormatKey) REFERENCES ORG01_DataFormat (DataFormatKey);
ALTER TABLE ORG01_PlatformAPI ADD CONSTRAINT ORG01_PlatformAPI_AuthMethod_FK FOREIGN KEY (AuthMethodKey) REFERENCES ORG01_AuthMethod (AuthMethodKey);
ALTER TABLE ORG01_PlatformAPI ADD CONSTRAINT ORG01_PlatformAPI_APIDirection_FK FOREIGN KEY (APIDirectionKey) REFERENCES ORG01_APIDirection (APIDirectionKey);
ALTER TABLE ORG01_APIVersion ADD CONSTRAINT ORG01_APIVersion_PlatformAPI_FK FOREIGN KEY (PlatformAPIKey) REFERENCES ORG01_PlatformAPI (PlatformAPIKey);
ALTER TABLE ORG01_APIEnvironment ADD CONSTRAINT ORG01_APIEnvironment_APIVersion_FK FOREIGN KEY (APIVersionKey) REFERENCES ORG01_APIVersion (APIVersionKey);
ALTER TABLE ORG01_APIEnvironment ADD CONSTRAINT ORG01_APIEnvironment_EnvironmentType_FK FOREIGN KEY (EnvironmentTypeKey) REFERENCES ORG01_EnvironmentType (EnvironmentTypeKey);
ALTER TABLE ORG01_APIEndpoint ADD CONSTRAINT ORG01_APIEndpoint_APIVersion_FK FOREIGN KEY (APIVersionKey) REFERENCES ORG01_APIVersion (APIVersionKey);
ALTER TABLE ORG01_APIEndpoint ADD CONSTRAINT ORG01_APIEndpoint_HTTPMethod_FK FOREIGN KEY (HTTPMethodKey) REFERENCES ORG01_HTTPMethod (HTTPMethodKey);
ALTER TABLE ORG01_APIEndpoint ADD CONSTRAINT ORG01_APIEndpoint_DataSubject_FK FOREIGN KEY (DataSubjectKey) REFERENCES ORG01_DataSubject (DataSubjectKey);
ALTER TABLE ORG01_EndpointResponse ADD CONSTRAINT ORG01_EndpointResponse_APIEndpoint_FK FOREIGN KEY (APIEndpointKey) REFERENCES ORG01_APIEndpoint (APIEndpointKey);
ALTER TABLE ORG01_EndpointResponse ADD CONSTRAINT ORG01_EndpointResponse_DataFormat_FK FOREIGN KEY (DataFormatKey) REFERENCES ORG01_DataFormat (DataFormatKey);
ALTER TABLE ORG01_EndpointData ADD CONSTRAINT ORG01_EndpointData_EndpointResponse_FK FOREIGN KEY (EndpointResponseKey) REFERENCES ORG01_EndpointResponse (EndpointResponseKey);
ALTER TABLE ORG01_EndpointData ADD CONSTRAINT ORG01_EndpointData_EndpointData_FK FOREIGN KEY (ParentEndpointDataKey) REFERENCES ORG01_EndpointData (EndpointDataKey);
ALTER TABLE ORG01_EndpointData ADD CONSTRAINT ORG01_EndpointData_FieldDataType_FK FOREIGN KEY (FieldDataTypeKey) REFERENCES ORG01_FieldDataType (FieldDataTypeKey);
ALTER TABLE ORG01_CanonicalField ADD CONSTRAINT ORG01_CanonicalField_DataSubject_FK FOREIGN KEY (DataSubjectKey) REFERENCES ORG01_DataSubject (DataSubjectKey);
ALTER TABLE ORG01_FieldMapping ADD CONSTRAINT ORG01_FieldMapping_EndpointData_FK FOREIGN KEY (EndpointDataKey) REFERENCES ORG01_EndpointData (EndpointDataKey);
ALTER TABLE ORG01_FieldMapping ADD CONSTRAINT ORG01_FieldMapping_CanonicalField_FK FOREIGN KEY (CanonicalFieldKey) REFERENCES ORG01_CanonicalField (CanonicalFieldKey);

-- Organizm 4: Odbiór danych z platformy
-- Każda dostawa danych: kiedy, którym endpointem, z jakim skutkiem – i surowa kopia każdego rekordu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
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
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
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
    EmployerAccountKey  NUMBER(7)     NOT NULL,
    SourcePlatformKey   NUMBER(4)     NOT NULL,
    ExternalAccountId   VARCHAR2(50)  NOT NULL,
    AccountTypeKey      NUMBER(2)     NOT NULL,
    FirstSeenAt         TIMESTAMP     NOT NULL
);

CREATE TABLE ORG05_EmployerAccountVersion (
    EmployerAccountVersionKey  NUMBER(8)      NOT NULL,
    EmployerAccountKey         NUMBER(7)      NOT NULL,
    AccountName                VARCHAR2(200)  NOT NULL,
    DeclaredNIP                VARCHAR2(10),
    WebsiteURL                 VARCHAR2(200),
    AccountStatusKey           NUMBER(2)      NOT NULL,
    IsVerifiedByPlatform       NUMBER(1)      NOT NULL,
    ValidFrom                  TIMESTAMP      NOT NULL,
    ValidTo                    TIMESTAMP,
    IsCurrent                  NUMBER(1)      NOT NULL,
    RawRecordKey               NUMBER(12)
);

COMMENT ON TABLE ORG05_AccountType IS 'Kto prowadzi konto.';
COMMENT ON COLUMN ORG05_AccountType.AccountTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_AccountType.AccountTypeName IS 'Nazwa rodzaju konta';

COMMENT ON TABLE ORG05_AccountStatus IS 'Stan konta na platformie.';
COMMENT ON COLUMN ORG05_AccountStatus.AccountStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_AccountStatus.AccountStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG05_EmployerAccount IS 'Konto na jednej platformie – to, co się nie zmienia.';
COMMENT ON COLUMN ORG05_EmployerAccount.EmployerAccountKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_EmployerAccount.SourcePlatformKey IS 'Platforma';
COMMENT ON COLUMN ORG05_EmployerAccount.ExternalAccountId IS 'Numer konta w serwisie';
COMMENT ON COLUMN ORG05_EmployerAccount.AccountTypeKey IS 'Kto prowadzi konto';
COMMENT ON COLUMN ORG05_EmployerAccount.FirstSeenAt IS 'Kiedy pierwszy raz dostaliśmy to konto';

COMMENT ON TABLE ORG05_EmployerAccountVersion IS 'Wersja danych konta – każda zmiana to nowy wiersz, aktualny jest jeden.';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.EmployerAccountVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.AccountName IS 'Nazwa konta';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.DeclaredNIP IS 'NIP wpisany przez właściciela konta (niesprawdzony)';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.WebsiteURL IS 'Strona www podana w koncie';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.AccountStatusKey IS 'Stan konta w tej wersji';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.IsVerifiedByPlatform IS '1 = platforma sama sprawdziła firmę';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.ValidFrom IS 'Od kiedy dane są takie';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.ValidTo IS 'Do kiedy (puste = wersja aktualna)';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.IsCurrent IS '1 = wersja aktualna';
COMMENT ON COLUMN ORG05_EmployerAccountVersion.RawRecordKey IS 'Rekord, z którego pochodzi ta wersja';

ALTER TABLE ORG05_AccountType ADD CONSTRAINT ORG05_AccountType_PK PRIMARY KEY (AccountTypeKey);
ALTER TABLE ORG05_AccountType ADD CONSTRAINT ORG05_AccountType_AccountTypeName_UN UNIQUE (AccountTypeName);
ALTER TABLE ORG05_AccountStatus ADD CONSTRAINT ORG05_AccountStatus_PK PRIMARY KEY (AccountStatusKey);
ALTER TABLE ORG05_AccountStatus ADD CONSTRAINT ORG05_AccountStatus_AccountStatusName_UN UNIQUE (AccountStatusName);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_PK PRIMARY KEY (EmployerAccountKey);
ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_UN UNIQUE (SourcePlatformKey, ExternalAccountId);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_PK PRIMARY KEY (EmployerAccountVersionKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_IsVerifiedByPlatform_CK CHECK (IsVerifiedByPlatform IN (0, 1));
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo > ValidFrom);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);

ALTER TABLE ORG05_EmployerAccount ADD CONSTRAINT ORG05_EmployerAccount_AccountType_FK FOREIGN KEY (AccountTypeKey) REFERENCES ORG05_AccountType (AccountTypeKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);
ALTER TABLE ORG05_EmployerAccountVersion ADD CONSTRAINT ORG05_EmployerAccountVersion_AccountStatus_FK FOREIGN KEY (AccountStatusKey) REFERENCES ORG05_AccountStatus (AccountStatusKey);

-- Organizm 6: Firma w rejestrach publicznych
-- Podmiot prawny stojący za ogłoszeniami, sprawdzony w rejestrach państwowych.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG06_LegalForm (
    LegalFormKey        NUMBER(2)     NOT NULL,
    LegalFormName       VARCHAR2(60)  NOT NULL,
    LegalFormShortName  VARCHAR2(20),
    LegalFormCode       CHAR(3)
);

CREATE TABLE ORG06_PKDClassification (
    PKDClassificationKey   NUMBER(1)     NOT NULL,
    PKDClassificationName  VARCHAR2(20)  NOT NULL,
    ValidFrom              DATE          NOT NULL
);

CREATE TABLE ORG06_PKDCode (
    PKDCodeKey            NUMBER(4)      NOT NULL,
    PKDSymbol             VARCHAR2(7)    NOT NULL,
    PKDName               VARCHAR2(250)  NOT NULL,
    PKDClassificationKey  NUMBER(1)      NOT NULL
);

CREATE TABLE ORG06_EmployerIdentifier (
    EmployerIdentifierKey  NUMBER(8)     NOT NULL,
    EmployerKey            NUMBER(7)     NOT NULL,
    IdentifierTypeKey      NUMBER(2)     NOT NULL,
    IdentifierValue        VARCHAR2(30)  NOT NULL,
    IsChecksumValid        NUMBER(1)     NOT NULL
);

CREATE TABLE ORG06_Employer (
    EmployerKey        NUMBER(7)      NOT NULL,
    OfficialName       VARCHAR2(250)  NOT NULL,
    LegalFormKey       NUMBER(2)      NOT NULL,
    CountryKey         NUMBER(3)      NOT NULL,
    EmployerStatusKey  NUMBER(2)      NOT NULL,
    RegistrationDate   DATE
);

CREATE TABLE ORG06_EmployerPKD (
    EmployerPKDKey  NUMBER(8)  NOT NULL,
    EmployerKey     NUMBER(7)  NOT NULL,
    PKDCodeKey      NUMBER(4)  NOT NULL,
    IsMainActivity  NUMBER(1)  NOT NULL,
    ValidFrom       DATE,
    ValidTo         DATE,
    IsCurrent       NUMBER(1)  NOT NULL
);

CREATE TABLE ORG06_IdentifierType (
    IdentifierTypeKey   NUMBER(2)     NOT NULL,
    IdentifierTypeName  VARCHAR2(40)  NOT NULL,
    ValueFormat         VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG06_RegistryCheck (
    RegistryCheckKey   NUMBER(9)      NOT NULL,
    EmployerKey        NUMBER(7)      NOT NULL,
    PublicRegistryKey  NUMBER(2)      NOT NULL,
    CheckedAt          TIMESTAMP      NOT NULL,
    WasFound           NUMBER(1)      NOT NULL,
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
COMMENT ON COLUMN ORG06_LegalForm.LegalFormCode IS 'Kod szczególnej formy prawnej z rejestru REGON, np. 117 – tekst, bo kody zaczynają się od zera (019, 048, 099)';

COMMENT ON TABLE ORG06_PKDClassification IS 'Wersja klasyfikacji PKD – wybierana z listy, a nie wpisywana.';
COMMENT ON COLUMN ORG06_PKDClassification.PKDClassificationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PKDClassification.PKDClassificationName IS 'Nazwa klasyfikacji';
COMMENT ON COLUMN ORG06_PKDClassification.ValidFrom IS 'Od kiedy obowiązuje';

COMMENT ON TABLE ORG06_PKDCode IS 'Rodzaj działalności z klasyfikacji PKD.';
COMMENT ON COLUMN ORG06_PKDCode.PKDCodeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_PKDCode.PKDSymbol IS 'Symbol, np. 52.10.B';
COMMENT ON COLUMN ORG06_PKDCode.PKDName IS 'Nazwa działalności';
COMMENT ON COLUMN ORG06_PKDCode.PKDClassificationKey IS 'Wersja klasyfikacji';

COMMENT ON TABLE ORG06_EmployerIdentifier IS 'Numer identyfikacyjny firmy – NIP, REGON, KRS albo numer zagraniczny.';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerIdentifierKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerIdentifier.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierTypeKey IS 'Rodzaj numeru';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IdentifierValue IS 'Numer – tekst, bo może zaczynać się od zera';
COMMENT ON COLUMN ORG06_EmployerIdentifier.IsChecksumValid IS '1 = numer przeszedł kontrolę sumy kontrolnej';

COMMENT ON TABLE ORG06_Employer IS 'Podmiot prawny – jeden wiersz to jedna prawdziwa firma. Dla niego liczymy Trust Score.';
COMMENT ON COLUMN ORG06_Employer.EmployerKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_Employer.OfficialName IS 'Nazwa urzędowa';
COMMENT ON COLUMN ORG06_Employer.LegalFormKey IS 'Forma prawna';
COMMENT ON COLUMN ORG06_Employer.CountryKey IS 'Kraj rejestracji';
COMMENT ON COLUMN ORG06_Employer.EmployerStatusKey IS 'Aktualny status';
COMMENT ON COLUMN ORG06_Employer.RegistrationDate IS 'Data wpisu do rejestru';

COMMENT ON TABLE ORG06_EmployerPKD IS 'Rodzaj działalności firmy – przypisanie w czasie firmy do kodu PKD.';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerPKDKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_EmployerPKD.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_EmployerPKD.PKDCodeKey IS 'Kod PKD';
COMMENT ON COLUMN ORG06_EmployerPKD.IsMainActivity IS '1 = działalność główna';
COMMENT ON COLUMN ORG06_EmployerPKD.ValidFrom IS 'Od kiedy firma prowadzi tę działalność (puste = nie wiemy)';
COMMENT ON COLUMN ORG06_EmployerPKD.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG06_EmployerPKD.IsCurrent IS '1 = działalność prowadzona teraz';

COMMENT ON TABLE ORG06_IdentifierType IS 'Rodzaj numeru identyfikacyjnego.';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_IdentifierType.IdentifierTypeName IS 'Nazwa rodzaju numeru';
COMMENT ON COLUMN ORG06_IdentifierType.ValueFormat IS 'Jak wygląda poprawny numer';

COMMENT ON TABLE ORG06_RegistryCheck IS 'Jedno sprawdzenie firmy w jednym rejestrze. Nowe sprawdzenie to nowy wiersz.';
COMMENT ON COLUMN ORG06_RegistryCheck.RegistryCheckKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG06_RegistryCheck.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG06_RegistryCheck.PublicRegistryKey IS 'Rejestr';
COMMENT ON COLUMN ORG06_RegistryCheck.CheckedAt IS 'Kiedy sprawdzono';
COMMENT ON COLUMN ORG06_RegistryCheck.WasFound IS '1 = rejestr znalazł firmę';
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
ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_LegalFormCode_UN UNIQUE (LegalFormCode);
ALTER TABLE ORG06_LegalForm ADD CONSTRAINT ORG06_LegalForm_CK1 CHECK (REGEXP_LIKE(LegalFormCode, '^[0-9]{3}$'));
ALTER TABLE ORG06_PKDClassification ADD CONSTRAINT ORG06_PKDClassification_PK PRIMARY KEY (PKDClassificationKey);
ALTER TABLE ORG06_PKDClassification ADD CONSTRAINT ORG06_PKDClassification_PKDClassificationName_UN UNIQUE (PKDClassificationName);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_PK PRIMARY KEY (PKDCodeKey);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_UN UNIQUE (PKDSymbol, PKDClassificationKey);
ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_CK1 CHECK (REGEXP_LIKE(PKDSymbol, '^[0-9]{2}\.[0-9]{2}\.[A-Z]$'));
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_PK PRIMARY KEY (EmployerIdentifierKey);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_UN UNIQUE (IdentifierTypeKey, IdentifierValue);
ALTER TABLE ORG06_EmployerIdentifier ADD CONSTRAINT ORG06_EmployerIdentifier_IsChecksumValid_CK CHECK (IsChecksumValid IN (0, 1));
ALTER TABLE ORG06_Employer ADD CONSTRAINT ORG06_Employer_PK PRIMARY KEY (EmployerKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_PK PRIMARY KEY (EmployerPKDKey);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_IsMainActivity_CK CHECK (IsMainActivity IN (0, 1));
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG06_EmployerPKD ADD CONSTRAINT ORG06_EmployerPKD_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_PK PRIMARY KEY (IdentifierTypeKey);
ALTER TABLE ORG06_IdentifierType ADD CONSTRAINT ORG06_IdentifierType_IdentifierTypeName_UN UNIQUE (IdentifierTypeName);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_PK PRIMARY KEY (RegistryCheckKey);
ALTER TABLE ORG06_RegistryCheck ADD CONSTRAINT ORG06_RegistryCheck_WasFound_CK CHECK (WasFound IN (0, 1));
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_PK PRIMARY KEY (EmployerStatusKey);
ALTER TABLE ORG06_EmployerStatus ADD CONSTRAINT ORG06_EmployerStatus_EmployerStatusName_UN UNIQUE (EmployerStatusName);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PK PRIMARY KEY (PublicRegistryKey);
ALTER TABLE ORG06_PublicRegistry ADD CONSTRAINT ORG06_PublicRegistry_PublicRegistryName_UN UNIQUE (PublicRegistryName);

ALTER TABLE ORG06_PKDCode ADD CONSTRAINT ORG06_PKDCode_PKDClassification_FK FOREIGN KEY (PKDClassificationKey) REFERENCES ORG06_PKDClassification (PKDClassificationKey);
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
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG07_MatchMethod (
    MatchMethodKey   NUMBER(2)     NOT NULL,
    MatchMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG07_LinkEvidence (
    LinkEvidenceKey         NUMBER(8)      NOT NULL,
    AccountEmployerLinkKey  NUMBER(8)      NOT NULL,
    EvidenceTypeKey         NUMBER(2)      NOT NULL,
    EvidenceValue           VARCHAR2(250)  NOT NULL
);

CREATE TABLE ORG07_AccountEmployerLink (
    AccountEmployerLinkKey  NUMBER(8)    NOT NULL,
    EmployerAccountKey      NUMBER(7)    NOT NULL,
    EmployerKey             NUMBER(7)    NOT NULL,
    MatchMethodKey          NUMBER(2)    NOT NULL,
    MatchConfidence         NUMBER(3,2)  NOT NULL,
    LinkedAt                TIMESTAMP    NOT NULL,
    UnlinkedAt              TIMESTAMP,
    IsActive                NUMBER(1)    NOT NULL
);

CREATE TABLE ORG07_AgencyClient (
    AgencyClientKey    NUMBER(6)  NOT NULL,
    AgencyEmployerKey  NUMBER(7)  NOT NULL,
    ClientEmployerKey  NUMBER(7)  NOT NULL,
    ValidFrom          DATE       NOT NULL,
    ValidTo            DATE,
    IsActive           NUMBER(1)  NOT NULL
);

CREATE TABLE ORG07_EvidenceType (
    EvidenceTypeKey   NUMBER(2)     NOT NULL,
    EvidenceTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG07_LinkChange (
    LinkChangeKey           NUMBER(8)      NOT NULL,
    AccountEmployerLinkKey  NUMBER(8)      NOT NULL,
    LinkChangeTypeKey       NUMBER(2)      NOT NULL,
    ChangedAt               TIMESTAMP      NOT NULL,
    ChangeReason            VARCHAR2(300),
    SystemUserKey           NUMBER(7)
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

COMMENT ON TABLE ORG07_AccountEmployerLink IS 'Powiązanie konta na platformie z firmą z rejestru – przypisanie w czasie; aktywne jest najwyżej jedno na konto.';
COMMENT ON COLUMN ORG07_AccountEmployerLink.AccountEmployerLinkKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_AccountEmployerLink.EmployerAccountKey IS 'Konto';
COMMENT ON COLUMN ORG07_AccountEmployerLink.EmployerKey IS 'Firma';
COMMENT ON COLUMN ORG07_AccountEmployerLink.MatchMethodKey IS 'Sposób dopasowania';
COMMENT ON COLUMN ORG07_AccountEmployerLink.MatchConfidence IS 'Pewność od 0 do 1';
COMMENT ON COLUMN ORG07_AccountEmployerLink.LinkedAt IS 'Kiedy połączono';
COMMENT ON COLUMN ORG07_AccountEmployerLink.UnlinkedAt IS 'Kiedy cofnięto (puste = obowiązuje)';
COMMENT ON COLUMN ORG07_AccountEmployerLink.IsActive IS '1 = powiązanie obowiązuje';

COMMENT ON TABLE ORG07_AgencyClient IS 'Agencja rekrutacyjna i firma, dla której rekrutuje – dwa klucze do tej samej tabeli, przypisanie w czasie.';
COMMENT ON COLUMN ORG07_AgencyClient.AgencyClientKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_AgencyClient.AgencyEmployerKey IS 'Agencja rekrutacyjna';
COMMENT ON COLUMN ORG07_AgencyClient.ClientEmployerKey IS 'Firma, dla której agencja rekrutuje';
COMMENT ON COLUMN ORG07_AgencyClient.ValidFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG07_AgencyClient.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG07_AgencyClient.IsActive IS '1 = współpraca trwa';

COMMENT ON TABLE ORG07_EvidenceType IS 'Rodzaj dowodu powiązania.';
COMMENT ON COLUMN ORG07_EvidenceType.EvidenceTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_EvidenceType.EvidenceTypeName IS 'Nazwa rodzaju dowodu';

COMMENT ON TABLE ORG07_LinkChange IS 'Zmiana powiązania – historia połączeń i rozłączeń, z autorem.';
COMMENT ON COLUMN ORG07_LinkChange.LinkChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkChange.AccountEmployerLinkKey IS 'Powiązanie';
COMMENT ON COLUMN ORG07_LinkChange.LinkChangeTypeKey IS 'Co zmieniono';
COMMENT ON COLUMN ORG07_LinkChange.ChangedAt IS 'Kiedy';
COMMENT ON COLUMN ORG07_LinkChange.ChangeReason IS 'Dlaczego';
COMMENT ON COLUMN ORG07_LinkChange.SystemUserKey IS 'Kto zmienił (puste = program)';

COMMENT ON TABLE ORG07_LinkChangeType IS 'Rodzaj zmiany powiązania.';
COMMENT ON COLUMN ORG07_LinkChangeType.LinkChangeTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG07_LinkChangeType.LinkChangeTypeName IS 'Nazwa rodzaju zmiany';

ALTER TABLE ORG07_MatchMethod ADD CONSTRAINT ORG07_MatchMethod_PK PRIMARY KEY (MatchMethodKey);
ALTER TABLE ORG07_MatchMethod ADD CONSTRAINT ORG07_MatchMethod_MatchMethodName_UN UNIQUE (MatchMethodName);
ALTER TABLE ORG07_LinkEvidence ADD CONSTRAINT ORG07_LinkEvidence_PK PRIMARY KEY (LinkEvidenceKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_PK PRIMARY KEY (AccountEmployerLinkKey);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_IsActive_CK CHECK (IsActive IN (0, 1));
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_CK1 CHECK (MatchConfidence BETWEEN 0 AND 1);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_CK2 CHECK (UnlinkedAt IS NULL OR UnlinkedAt >= LinkedAt);
ALTER TABLE ORG07_AccountEmployerLink ADD CONSTRAINT ORG07_AccountEmployerLink_CK3 CHECK (IsActive = 1 OR UnlinkedAt IS NOT NULL);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_PK PRIMARY KEY (AgencyClientKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_UN UNIQUE (AgencyEmployerKey, ClientEmployerKey, ValidFrom);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_IsActive_CK CHECK (IsActive IN (0, 1));
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_CK1 CHECK (AgencyEmployerKey <> ClientEmployerKey);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_CK2 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG07_AgencyClient ADD CONSTRAINT ORG07_AgencyClient_CK3 CHECK (IsActive = 1 OR ValidTo IS NOT NULL);
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
-- Samo ogłoszenie: kto je opublikował, kiedy, dla jakich poziomów, w jakich trybach i w których miejscowościach.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
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
    JobPostingKey       NUMBER(9)      NOT NULL,
    EmployerAccountKey  NUMBER(7)      NOT NULL,
    ExternalPostingId   VARCHAR2(50)   NOT NULL,
    PostingTitle        VARCHAR2(200)  NOT NULL,
    PostingStatusKey    NUMBER(2)      NOT NULL,
    VacancyCount        NUMBER(3),
    PublishedDate       DATE           NOT NULL,
    ExpiryDate          DATE,
    RawRecordKey        NUMBER(12)
);

CREATE TABLE ORG08_PostingSeniority (
    PostingSeniorityKey  NUMBER(9)  NOT NULL,
    JobPostingKey        NUMBER(9)  NOT NULL,
    SeniorityLevelKey    NUMBER(2)  NOT NULL
);

CREATE TABLE ORG08_WorkMode (
    WorkModeKey   NUMBER(2)     NOT NULL,
    WorkModeName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG08_PostingWorkMode (
    PostingWorkModeKey  NUMBER(9)  NOT NULL,
    JobPostingKey       NUMBER(9)  NOT NULL,
    WorkModeKey         NUMBER(2)  NOT NULL
);

CREATE TABLE ORG08_PostingLocation (
    PostingLocationKey  NUMBER(9)  NOT NULL,
    JobPostingKey       NUMBER(9)  NOT NULL,
    LocationKey         NUMBER(6)  NOT NULL,
    IsMainLocation      NUMBER(1)  NOT NULL
);

CREATE TABLE ORG08_Location (
    LocationKey  NUMBER(6)     NOT NULL,
    CityName     VARCHAR2(80)  NOT NULL,
    SIMCCode     CHAR(7),
    RegionKey    NUMBER(3),
    CountryKey   NUMBER(3)     NOT NULL
);

CREATE TABLE ORG08_Region (
    RegionKey   NUMBER(3)     NOT NULL,
    RegionName  VARCHAR2(80)  NOT NULL,
    RegionCode  CHAR(2),
    CountryKey  NUMBER(3)     NOT NULL
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
COMMENT ON COLUMN ORG08_JobPosting.VacancyCount IS 'Ilu osób szuka';
COMMENT ON COLUMN ORG08_JobPosting.PublishedDate IS 'Data pierwszej publikacji';
COMMENT ON COLUMN ORG08_JobPosting.ExpiryDate IS 'Planowana data końca';
COMMENT ON COLUMN ORG08_JobPosting.RawRecordKey IS 'Rekord, z którego powstało ogłoszenie';

COMMENT ON TABLE ORG08_PostingSeniority IS 'Poziom stanowiska w ogłoszeniu – tabela łącząca, bo ogłoszenie bywa dla kilku poziomów naraz.';
COMMENT ON COLUMN ORG08_PostingSeniority.PostingSeniorityKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_PostingSeniority.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG08_PostingSeniority.SeniorityLevelKey IS 'Poziom';

COMMENT ON TABLE ORG08_WorkMode IS 'Tryb pracy.';
COMMENT ON COLUMN ORG08_WorkMode.WorkModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_WorkMode.WorkModeName IS 'Nazwa trybu pracy';

COMMENT ON TABLE ORG08_PostingWorkMode IS 'Tryb pracy w ogłoszeniu – tabela łącząca, bo ogłoszenie daje kilka trybów do wyboru.';
COMMENT ON COLUMN ORG08_PostingWorkMode.PostingWorkModeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_PostingWorkMode.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG08_PostingWorkMode.WorkModeKey IS 'Tryb pracy';

COMMENT ON TABLE ORG08_PostingLocation IS 'Miejsce pracy w ogłoszeniu – tabela łącząca ogłoszenia z miejscowościami.';
COMMENT ON COLUMN ORG08_PostingLocation.PostingLocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_PostingLocation.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG08_PostingLocation.LocationKey IS 'Miejscowość';
COMMENT ON COLUMN ORG08_PostingLocation.IsMainLocation IS '1 = główne miejsce pracy';

COMMENT ON TABLE ORG08_Location IS 'Miejscowość – z urzędowym kodem TERYT, gdy leży w Polsce.';
COMMENT ON COLUMN ORG08_Location.LocationKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_Location.CityName IS 'Nazwa miejscowości';
COMMENT ON COLUMN ORG08_Location.SIMCCode IS 'Identyfikator miejscowości z rejestru TERYT (SIMC), np. 0950463 – Kraków (puste za granicą)';
COMMENT ON COLUMN ORG08_Location.RegionKey IS 'Województwo albo region (puste, gdy nie wiemy)';
COMMENT ON COLUMN ORG08_Location.CountryKey IS 'Kraj';

COMMENT ON TABLE ORG08_Region IS 'Województwo albo region – wybierane z listy, a nie wpisywane.';
COMMENT ON COLUMN ORG08_Region.RegionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG08_Region.RegionName IS 'Nazwa, np. małopolskie';
COMMENT ON COLUMN ORG08_Region.RegionCode IS 'Kod województwa z rejestru TERYT, np. 12 (puste za granicą)';
COMMENT ON COLUMN ORG08_Region.CountryKey IS 'Kraj';

ALTER TABLE ORG08_PostingStatus ADD CONSTRAINT ORG08_PostingStatus_PK PRIMARY KEY (PostingStatusKey);
ALTER TABLE ORG08_PostingStatus ADD CONSTRAINT ORG08_PostingStatus_PostingStatusName_UN UNIQUE (PostingStatusName);
ALTER TABLE ORG08_SeniorityLevel ADD CONSTRAINT ORG08_SeniorityLevel_PK PRIMARY KEY (SeniorityLevelKey);
ALTER TABLE ORG08_SeniorityLevel ADD CONSTRAINT ORG08_SeniorityLevel_SeniorityLevelName_UN UNIQUE (SeniorityLevelName);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_PK PRIMARY KEY (JobPostingKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_UN UNIQUE (EmployerAccountKey, ExternalPostingId);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_CK1 CHECK (ExpiryDate IS NULL OR ExpiryDate >= PublishedDate);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_CK2 CHECK (VacancyCount > 0);
ALTER TABLE ORG08_PostingSeniority ADD CONSTRAINT ORG08_PostingSeniority_PK PRIMARY KEY (PostingSeniorityKey);
ALTER TABLE ORG08_PostingSeniority ADD CONSTRAINT ORG08_PostingSeniority_UN UNIQUE (JobPostingKey, SeniorityLevelKey);
ALTER TABLE ORG08_WorkMode ADD CONSTRAINT ORG08_WorkMode_PK PRIMARY KEY (WorkModeKey);
ALTER TABLE ORG08_WorkMode ADD CONSTRAINT ORG08_WorkMode_WorkModeName_UN UNIQUE (WorkModeName);
ALTER TABLE ORG08_PostingWorkMode ADD CONSTRAINT ORG08_PostingWorkMode_PK PRIMARY KEY (PostingWorkModeKey);
ALTER TABLE ORG08_PostingWorkMode ADD CONSTRAINT ORG08_PostingWorkMode_UN UNIQUE (JobPostingKey, WorkModeKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_PK PRIMARY KEY (PostingLocationKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_UN UNIQUE (JobPostingKey, LocationKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_IsMainLocation_CK CHECK (IsMainLocation IN (0, 1));
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_PK PRIMARY KEY (LocationKey);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_SIMCCode_UN UNIQUE (SIMCCode);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_CK1 CHECK (REGEXP_LIKE(SIMCCode, '^[0-9]{7}$'));
ALTER TABLE ORG08_Region ADD CONSTRAINT ORG08_Region_PK PRIMARY KEY (RegionKey);
ALTER TABLE ORG08_Region ADD CONSTRAINT ORG08_Region_UN1 UNIQUE (CountryKey, RegionName);
ALTER TABLE ORG08_Region ADD CONSTRAINT ORG08_Region_UN2 UNIQUE (CountryKey, RegionCode);
ALTER TABLE ORG08_Region ADD CONSTRAINT ORG08_Region_CK1 CHECK (REGEXP_LIKE(RegionCode, '^[0-9]{2}$'));

ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_PostingStatus_FK FOREIGN KEY (PostingStatusKey) REFERENCES ORG08_PostingStatus (PostingStatusKey);
ALTER TABLE ORG08_PostingSeniority ADD CONSTRAINT ORG08_PostingSeniority_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG08_PostingSeniority ADD CONSTRAINT ORG08_PostingSeniority_SeniorityLevel_FK FOREIGN KEY (SeniorityLevelKey) REFERENCES ORG08_SeniorityLevel (SeniorityLevelKey);
ALTER TABLE ORG08_PostingWorkMode ADD CONSTRAINT ORG08_PostingWorkMode_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG08_PostingWorkMode ADD CONSTRAINT ORG08_PostingWorkMode_WorkMode_FK FOREIGN KEY (WorkModeKey) REFERENCES ORG08_WorkMode (WorkModeKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG08_PostingLocation ADD CONSTRAINT ORG08_PostingLocation_Location_FK FOREIGN KEY (LocationKey) REFERENCES ORG08_Location (LocationKey);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_Region_FK FOREIGN KEY (RegionKey) REFERENCES ORG08_Region (RegionKey);

-- Organizm 9: Warunki zatrudnienia
-- Na jakiej umowie, za ile i z jakimi dodatkami – obietnica, którą firma składa w ogłoszeniu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
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
    PostingSalaryKey  NUMBER(9)     NOT NULL,
    JobPostingKey     NUMBER(9)     NOT NULL,
    ContractTypeKey   NUMBER(2)     NOT NULL,
    SalaryFrom        NUMBER(10,2),
    SalaryTo          NUMBER(10,2),
    CurrencyKey       NUMBER(3),
    SalaryPeriodKey   NUMBER(2),
    IsGross           NUMBER(1),
    ValidFrom         TIMESTAMP     NOT NULL,
    ValidTo           TIMESTAMP,
    IsCurrent         NUMBER(1)     NOT NULL
);

CREATE TABLE ORG09_PostingBenefit (
    PostingBenefitKey  NUMBER(9)  NOT NULL,
    JobPostingKey      NUMBER(9)  NOT NULL,
    BenefitKey         NUMBER(4)  NOT NULL
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
COMMENT ON COLUMN ORG09_Currency.CurrencyCode IS 'Kod waluty ISO 4217, np. PLN';
COMMENT ON COLUMN ORG09_Currency.CurrencyName IS 'Nazwa waluty';

COMMENT ON TABLE ORG09_ContractType IS 'Rodzaj umowy.';
COMMENT ON COLUMN ORG09_ContractType.ContractTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_ContractType.ContractTypeName IS 'Nazwa rodzaju umowy';

COMMENT ON TABLE ORG09_SalaryPeriod IS 'Okres, za który podano kwotę.';
COMMENT ON COLUMN ORG09_SalaryPeriod.SalaryPeriodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_SalaryPeriod.SalaryPeriodName IS 'Nazwa okresu';

COMMENT ON TABLE ORG09_PostingSalary IS 'Umowa z widełkami w ogłoszeniu – kilka umów na ogłoszenie, z historią zmian.';
COMMENT ON COLUMN ORG09_PostingSalary.PostingSalaryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG09_PostingSalary.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG09_PostingSalary.ContractTypeKey IS 'Rodzaj umowy';
COMMENT ON COLUMN ORG09_PostingSalary.SalaryFrom IS 'Widełki od (puste = nie podano)';
COMMENT ON COLUMN ORG09_PostingSalary.SalaryTo IS 'Widełki do';
COMMENT ON COLUMN ORG09_PostingSalary.CurrencyKey IS 'Waluta (puste, gdy brak kwoty)';
COMMENT ON COLUMN ORG09_PostingSalary.SalaryPeriodKey IS 'Za jaki okres (puste, gdy brak kwoty)';
COMMENT ON COLUMN ORG09_PostingSalary.IsGross IS '1 = kwota brutto, 0 = netto';
COMMENT ON COLUMN ORG09_PostingSalary.ValidFrom IS 'Od kiedy ogłoszenie podawało te warunki';
COMMENT ON COLUMN ORG09_PostingSalary.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG09_PostingSalary.IsCurrent IS '1 = warunki aktualne';

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
ALTER TABLE ORG09_Currency ADD CONSTRAINT ORG09_Currency_CK1 CHECK (REGEXP_LIKE(CurrencyCode, '^[A-Z]{3}$'));
ALTER TABLE ORG09_ContractType ADD CONSTRAINT ORG09_ContractType_PK PRIMARY KEY (ContractTypeKey);
ALTER TABLE ORG09_ContractType ADD CONSTRAINT ORG09_ContractType_ContractTypeName_UN UNIQUE (ContractTypeName);
ALTER TABLE ORG09_SalaryPeriod ADD CONSTRAINT ORG09_SalaryPeriod_PK PRIMARY KEY (SalaryPeriodKey);
ALTER TABLE ORG09_SalaryPeriod ADD CONSTRAINT ORG09_SalaryPeriod_SalaryPeriodName_UN UNIQUE (SalaryPeriodName);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_PK PRIMARY KEY (PostingSalaryKey);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_IsGross_CK CHECK (IsGross IN (0, 1));
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_CK1 CHECK (SalaryFrom IS NULL OR SalaryTo IS NULL OR SalaryFrom <= SalaryTo);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_CK2 CHECK (SalaryFrom >= 0 AND SalaryTo >= 0);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_CK3 CHECK ((SalaryFrom IS NULL AND SalaryTo IS NULL) OR (CurrencyKey IS NOT NULL AND SalaryPeriodKey IS NOT NULL));
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_CK4 CHECK (ValidTo IS NULL OR ValidTo > ValidFrom);
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_CK5 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
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
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG10_RequirementLevel (
    RequirementLevelKey   NUMBER(1)     NOT NULL,
    RequirementLevelName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG10_PostingResponsibility (
    PostingResponsibilityKey  NUMBER(9)      NOT NULL,
    JobPostingKey             NUMBER(9)      NOT NULL,
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
    PostingRequirementKey  NUMBER(9)  NOT NULL,
    JobPostingKey          NUMBER(9)  NOT NULL,
    SkillKey               NUMBER(5)  NOT NULL,
    RequirementLevelKey    NUMBER(1)  NOT NULL,
    ProficiencyLevelKey    NUMBER(3),
    MinYearsExperience     NUMBER(2),
    ExtractionMethodKey    NUMBER(2)  NOT NULL
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
    SkillKey          NUMBER(5)     NOT NULL,
    SkillName         VARCHAR2(80)  NOT NULL,
    SkillCategoryKey  NUMBER(2)     NOT NULL
);

CREATE TABLE ORG10_SkillSynonym (
    SkillSynonymKey  NUMBER(6)     NOT NULL,
    SkillKey         NUMBER(5)     NOT NULL,
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
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_CK1 CHECK (MinYearsExperience >= 0);
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
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG11_EventSource (
    EventSourceKey   NUMBER(1)     NOT NULL,
    EventSourceName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG11_PostingEventType (
    PostingEventTypeKey   NUMBER(2)     NOT NULL,
    PostingEventTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG11_PostingEvent (
    PostingEventKey      NUMBER(10)  NOT NULL,
    JobPostingKey        NUMBER(9)   NOT NULL,
    PostingEventTypeKey  NUMBER(2)   NOT NULL,
    EventSourceKey       NUMBER(1)   NOT NULL,
    OccurredAt           TIMESTAMP   NOT NULL,
    DataDeliveryKey      NUMBER(10),
    SystemUserKey        NUMBER(7)
);

CREATE TABLE ORG11_PostingVersion (
    PostingVersionKey  NUMBER(9)      NOT NULL,
    JobPostingKey      NUMBER(9)      NOT NULL,
    VersionNumber      NUMBER(3)      NOT NULL,
    VersionTitle       VARCHAR2(200)  NOT NULL,
    OriginalText       CLOB           NOT NULL,
    CleanText          CLOB,
    TextHash           VARCHAR2(64)   NOT NULL,
    ValidFrom          TIMESTAMP      NOT NULL,
    ValidTo            TIMESTAMP,
    IsCurrent          NUMBER(1)      NOT NULL
);

CREATE TABLE ORG11_BoilerplatePattern (
    BoilerplatePatternKey  NUMBER(6)       NOT NULL,
    BoilerplateTypeKey     NUMBER(2)       NOT NULL,
    PatternText            VARCHAR2(1000)  NOT NULL,
    EmployerKey            NUMBER(7)
);

CREATE TABLE ORG11_VersionBoilerplate (
    VersionBoilerplateKey  NUMBER(10)  NOT NULL,
    PostingVersionKey      NUMBER(9)   NOT NULL,
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
COMMENT ON COLUMN ORG11_PostingEvent.SystemUserKey IS 'Kto wpisał zdarzenie ręcznie (puste = platforma albo program)';

COMMENT ON TABLE ORG11_PostingVersion IS 'Wersja treści ogłoszenia – każda edycja to nowy wiersz, aktualna jest jedna.';
COMMENT ON COLUMN ORG11_PostingVersion.PostingVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG11_PostingVersion.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG11_PostingVersion.VersionNumber IS 'Numer wersji (1, 2, 3…)';
COMMENT ON COLUMN ORG11_PostingVersion.VersionTitle IS 'Tytuł w tej wersji';
COMMENT ON COLUMN ORG11_PostingVersion.OriginalText IS 'Treść tak, jak przyszła';
COMMENT ON COLUMN ORG11_PostingVersion.CleanText IS 'Treść bez stopek i klauzul';
COMMENT ON COLUMN ORG11_PostingVersion.TextHash IS 'Skrót treści – szybkie porównanie wersji';
COMMENT ON COLUMN ORG11_PostingVersion.ValidFrom IS 'Od kiedy treść była taka';
COMMENT ON COLUMN ORG11_PostingVersion.ValidTo IS 'Do kiedy (puste = aktualna)';
COMMENT ON COLUMN ORG11_PostingVersion.IsCurrent IS '1 = wersja aktualna';

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
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo > ValidFrom);
ALTER TABLE ORG11_PostingVersion ADD CONSTRAINT ORG11_PostingVersion_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
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
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG12_SimilarityType (
    SimilarityTypeKey   NUMBER(2)     NOT NULL,
    SimilarityTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG12_SimilarityMethod (
    SimilarityMethodKey   NUMBER(2)     NOT NULL,
    SimilarityMethodName  VARCHAR2(60)  NOT NULL
);

CREATE TABLE ORG12_SimilarityMethodVersion (
    SimilarityMethodVersionKey  NUMBER(3)     NOT NULL,
    SimilarityMethodKey         NUMBER(2)     NOT NULL,
    VersionLabel                VARCHAR2(20)  NOT NULL,
    ValidFrom                   DATE          NOT NULL,
    ValidTo                     DATE,
    IsCurrent                   NUMBER(1)     NOT NULL
);

CREATE TABLE ORG12_SimilarityPair (
    SimilarityPairKey           NUMBER(10)   NOT NULL,
    FirstJobPostingKey          NUMBER(9)    NOT NULL,
    SecondJobPostingKey         NUMBER(9)    NOT NULL,
    SimilarityTypeKey           NUMBER(2)    NOT NULL,
    SimilarityMethodVersionKey  NUMBER(3)    NOT NULL,
    SimilarityScore             NUMBER(4,3)  NOT NULL,
    DetectedAt                  TIMESTAMP    NOT NULL
);

CREATE TABLE ORG12_FamilyMember (
    FamilyMemberKey   NUMBER(9)  NOT NULL,
    PostingFamilyKey  NUMBER(8)  NOT NULL,
    JobPostingKey     NUMBER(9)  NOT NULL,
    AddedAt           TIMESTAMP  NOT NULL,
    RemovedAt         TIMESTAMP,
    IsCurrent         NUMBER(1)  NOT NULL
);

CREATE TABLE ORG12_PostingFamily (
    PostingFamilyKey  NUMBER(8)      NOT NULL,
    EmployerKey       NUMBER(7)      NOT NULL,
    FamilyLabel       VARCHAR2(200)  NOT NULL,
    FirstSeenDate     DATE           NOT NULL,
    LastSeenDate      DATE           NOT NULL
);

CREATE TABLE ORG12_FamilyLifecycle (
    FamilyLifecycleKey     NUMBER(10)  NOT NULL,
    PostingFamilyKey       NUMBER(8)   NOT NULL,
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

COMMENT ON TABLE ORG12_SimilarityMethod IS 'Metoda liczenia podobieństwa – nazwa wybierana z listy.';
COMMENT ON COLUMN ORG12_SimilarityMethod.SimilarityMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityMethod.SimilarityMethodName IS 'Nazwa metody';

COMMENT ON TABLE ORG12_SimilarityMethodVersion IS 'Wersja metody liczenia podobieństwa – z jednej wersji każdej metody korzystamy teraz.';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.SimilarityMethodVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.SimilarityMethodKey IS 'Metoda';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.VersionLabel IS 'Wersja, np. 1.0';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.ValidFrom IS 'Od kiedy używana';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG12_SimilarityMethodVersion.IsCurrent IS '1 = wersja używana teraz';

COMMENT ON TABLE ORG12_SimilarityPair IS 'Para podobnych ogłoszeń – dwa klucze obce do tej samej tabeli.';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityPairKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_SimilarityPair.FirstJobPostingKey IS 'Pierwsze ogłoszenie (wcześniejsze)';
COMMENT ON COLUMN ORG12_SimilarityPair.SecondJobPostingKey IS 'Drugie ogłoszenie';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityTypeKey IS 'Rodzaj powtórki';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityMethodVersionKey IS 'Metoda w konkretnej wersji';
COMMENT ON COLUMN ORG12_SimilarityPair.SimilarityScore IS 'Podobieństwo od 0 do 1';
COMMENT ON COLUMN ORG12_SimilarityPair.DetectedAt IS 'Kiedy wykryto';

COMMENT ON TABLE ORG12_FamilyMember IS 'Ogłoszenie w rodzinie – przypisanie w czasie; w danej chwili ogłoszenie jest najwyżej w jednej rodzinie.';
COMMENT ON COLUMN ORG12_FamilyMember.FamilyMemberKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG12_FamilyMember.PostingFamilyKey IS 'Rodzina';
COMMENT ON COLUMN ORG12_FamilyMember.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN ORG12_FamilyMember.AddedAt IS 'Kiedy dołączono do rodziny';
COMMENT ON COLUMN ORG12_FamilyMember.RemovedAt IS 'Kiedy przeniesiono do innej rodziny (puste = nadal)';
COMMENT ON COLUMN ORG12_FamilyMember.IsCurrent IS '1 = członkostwo aktualne';

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
ALTER TABLE ORG12_SimilarityMethod ADD CONSTRAINT ORG12_SimilarityMethod_SimilarityMethodName_UN UNIQUE (SimilarityMethodName);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_PK PRIMARY KEY (SimilarityMethodVersionKey);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_UN UNIQUE (SimilarityMethodKey, VersionLabel);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_PK PRIMARY KEY (SimilarityPairKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_UN UNIQUE (FirstJobPostingKey, SecondJobPostingKey, SimilarityMethodVersionKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_CK1 CHECK (FirstJobPostingKey < SecondJobPostingKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_CK2 CHECK (SimilarityScore BETWEEN 0 AND 1);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_PK PRIMARY KEY (FamilyMemberKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_CK1 CHECK (RemovedAt IS NULL OR RemovedAt >= AddedAt);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_CK2 CHECK (IsCurrent = 1 OR RemovedAt IS NOT NULL);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_PK PRIMARY KEY (PostingFamilyKey);
ALTER TABLE ORG12_PostingFamily ADD CONSTRAINT ORG12_PostingFamily_CK1 CHECK (LastSeenDate >= FirstSeenDate);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_PK PRIMARY KEY (FamilyLifecycleKey);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_UN UNIQUE (PostingFamilyKey, CalculatedOn);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_CK1 CHECK (PublicationCount >= 0 AND VisibleDays >= 0 AND GapCount >= 0 AND RefreshCount >= 0 AND PlatformCount >= 0 AND SeniorityVariantCount >= 0);

ALTER TABLE ORG12_SimilarityMethodVersion ADD CONSTRAINT ORG12_SimilarityMethodVersion_SimilarityMethod_FK FOREIGN KEY (SimilarityMethodKey) REFERENCES ORG12_SimilarityMethod (SimilarityMethodKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SimilarityType_FK FOREIGN KEY (SimilarityTypeKey) REFERENCES ORG12_SimilarityType (SimilarityTypeKey);
ALTER TABLE ORG12_SimilarityPair ADD CONSTRAINT ORG12_SimilarityPair_SimilarityMethodVersion_FK FOREIGN KEY (SimilarityMethodVersionKey) REFERENCES ORG12_SimilarityMethodVersion (SimilarityMethodVersionKey);
ALTER TABLE ORG12_FamilyMember ADD CONSTRAINT ORG12_FamilyMember_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES ORG12_PostingFamily (PostingFamilyKey);
ALTER TABLE ORG12_FamilyLifecycle ADD CONSTRAINT ORG12_FamilyLifecycle_PostingFamily_FK FOREIGN KEY (PostingFamilyKey) REFERENCES ORG12_PostingFamily (PostingFamilyKey);

-- Organizm 13: Kandydat, aplikacje i zgody
-- Osoba znana tylko z pseudonimu, jej aplikacje potwierdzone przez platformę i jej zgody.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG13_CandidatePseudonym (
    CandidatePseudonymKey  NUMBER(9)     NOT NULL,
    SourcePlatformKey      NUMBER(4)     NOT NULL,
    PseudonymValue         VARCHAR2(64)  NOT NULL,
    FirstSeenAt            TIMESTAMP     NOT NULL
);

CREATE TABLE ORG13_Application (
    ApplicationKey         NUMBER(10)  NOT NULL,
    CandidatePseudonymKey  NUMBER(9)   NOT NULL,
    JobPostingKey          NUMBER(9)   NOT NULL,
    AppliedAt              TIMESTAMP   NOT NULL,
    DataDeliveryKey        NUMBER(10)
);

CREATE TABLE ORG13_Consent (
    ConsentKey             NUMBER(9)  NOT NULL,
    CandidatePseudonymKey  NUMBER(9)  NOT NULL,
    ConsentTextVersionKey  NUMBER(3)  NOT NULL,
    IsGranted              NUMBER(1)  NOT NULL,
    DecidedAt              TIMESTAMP  NOT NULL
);

CREATE TABLE ORG13_ApplicationStatusChange (
    ApplicationStatusChangeKey  NUMBER(10)  NOT NULL,
    ApplicationKey              NUMBER(10)  NOT NULL,
    ApplicationStatusKey        NUMBER(2)   NOT NULL,
    ChangedAt                   TIMESTAMP   NOT NULL,
    IsCurrent                   NUMBER(1)   NOT NULL
);

CREATE TABLE ORG13_ApplicationStatus (
    ApplicationStatusKey   NUMBER(2)     NOT NULL,
    ApplicationStatusName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG13_ConsentTextVersion (
    ConsentTextVersionKey  NUMBER(3)     NOT NULL,
    ConsentTypeKey         NUMBER(2)     NOT NULL,
    VersionLabel           VARCHAR2(10)  NOT NULL,
    ConsentText            CLOB          NOT NULL,
    ValidFrom              DATE          NOT NULL,
    ValidTo                DATE,
    IsCurrent              NUMBER(1)     NOT NULL
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
COMMENT ON COLUMN ORG13_Consent.IsGranted IS '1 = zgoda udzielona, 0 = wycofana';
COMMENT ON COLUMN ORG13_Consent.DecidedAt IS 'Kiedy';

COMMENT ON TABLE ORG13_ApplicationStatusChange IS 'Zmiana stanu aplikacji – historia; aktualny stan jest jeden.';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationStatusChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationKey IS 'Aplikacja';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ApplicationStatusKey IS 'Nowy stan';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.ChangedAt IS 'Kiedy';
COMMENT ON COLUMN ORG13_ApplicationStatusChange.IsCurrent IS '1 = stan aktualny';

COMMENT ON TABLE ORG13_ApplicationStatus IS 'Stan aplikacji.';
COMMENT ON COLUMN ORG13_ApplicationStatus.ApplicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ApplicationStatus.ApplicationStatusName IS 'Nazwa stanu';

COMMENT ON TABLE ORG13_ConsentTextVersion IS 'Wersja treści zgody, którą kandydat zobaczył; aktualna jest jedna na rodzaj zgody.';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentTextVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentTypeKey IS 'Na co jest zgoda';
COMMENT ON COLUMN ORG13_ConsentTextVersion.VersionLabel IS 'Oznaczenie wersji, np. 1.2';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ConsentText IS 'Pełna treść zgody';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ValidFrom IS 'Od kiedy pokazywana';
COMMENT ON COLUMN ORG13_ConsentTextVersion.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG13_ConsentTextVersion.IsCurrent IS '1 = wersja pokazywana teraz';

COMMENT ON TABLE ORG13_ConsentType IS 'Na co kandydat się zgadza.';
COMMENT ON COLUMN ORG13_ConsentType.ConsentTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG13_ConsentType.ConsentTypeName IS 'Nazwa zgody';

ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_PK PRIMARY KEY (CandidatePseudonymKey);
ALTER TABLE ORG13_CandidatePseudonym ADD CONSTRAINT ORG13_CandidatePseudonym_UN UNIQUE (SourcePlatformKey, PseudonymValue);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_PK PRIMARY KEY (ApplicationKey);
ALTER TABLE ORG13_Application ADD CONSTRAINT ORG13_Application_UN UNIQUE (CandidatePseudonymKey, JobPostingKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_PK PRIMARY KEY (ConsentKey);
ALTER TABLE ORG13_Consent ADD CONSTRAINT ORG13_Consent_IsGranted_CK CHECK (IsGranted IN (0, 1));
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_PK PRIMARY KEY (ApplicationStatusChangeKey);
ALTER TABLE ORG13_ApplicationStatusChange ADD CONSTRAINT ORG13_ApplicationStatusChange_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG13_ApplicationStatus ADD CONSTRAINT ORG13_ApplicationStatus_PK PRIMARY KEY (ApplicationStatusKey);
ALTER TABLE ORG13_ApplicationStatus ADD CONSTRAINT ORG13_ApplicationStatus_ApplicationStatusName_UN UNIQUE (ApplicationStatusName);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_PK PRIMARY KEY (ConsentTextVersionKey);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_UN UNIQUE (ConsentTypeKey, VersionLabel);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG13_ConsentTextVersion ADD CONSTRAINT ORG13_ConsentTextVersion_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
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
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG14_ReportOutcome (
    ReportOutcomeKey   NUMBER(2)     NOT NULL,
    ReportOutcomeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG14_RecruitmentReport (
    RecruitmentReportKey   NUMBER(9)   NOT NULL,
    CandidatePseudonymKey  NUMBER(9)   NOT NULL,
    JobPostingKey          NUMBER(9)   NOT NULL,
    ReportOutcomeKey       NUMBER(2)   NOT NULL,
    RecruitmentStageKey    NUMBER(2)   NOT NULL,
    ReportChannelKey       NUMBER(1)   NOT NULL,
    ReminderKey            NUMBER(10),
    ReportedAt             TIMESTAMP   NOT NULL
);

CREATE TABLE ORG14_Reminder (
    ReminderKey        NUMBER(10)  NOT NULL,
    ApplicationKey     NUMBER(10)  NOT NULL,
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
    ReportChannelKey   NUMBER(1)     NOT NULL,
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
ALTER TABLE ORG14_Reminder ADD CONSTRAINT ORG14_Reminder_CK1 CHECK (ReminderNumber >= 1);
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
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG15_CheckType (
    CheckTypeKey   NUMBER(2)     NOT NULL,
    CheckTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG15_VerdictDecision (
    VerdictDecisionKey   NUMBER(1)     NOT NULL,
    VerdictDecisionName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE ORG15_ReportCheck (
    ReportCheckKey        NUMBER(10)     NOT NULL,
    RecruitmentReportKey  NUMBER(9)      NOT NULL,
    CheckTypeKey          NUMBER(2)      NOT NULL,
    CheckResultKey        NUMBER(1)      NOT NULL,
    CheckedAt             TIMESTAMP      NOT NULL,
    CheckDetails          VARCHAR2(400)
);

CREATE TABLE ORG15_ReportVerdict (
    ReportVerdictKey      NUMBER(10)   NOT NULL,
    RecruitmentReportKey  NUMBER(9)    NOT NULL,
    VerdictDecisionKey    NUMBER(1)    NOT NULL,
    VerdictRuleSetKey     NUMBER(3)    NOT NULL,
    ReportWeight          NUMBER(3,2)  NOT NULL,
    DecidedAt             TIMESTAMP    NOT NULL,
    IsCurrent             NUMBER(1)    NOT NULL,
    SystemUserKey         NUMBER(7)
);

CREATE TABLE ORG15_VerdictRuleSet (
    VerdictRuleSetKey  NUMBER(3)      NOT NULL,
    VersionLabel       VARCHAR2(20)   NOT NULL,
    RuleDescription    VARCHAR2(300)  NOT NULL,
    ValidFrom          DATE           NOT NULL,
    ValidTo            DATE,
    IsCurrent          NUMBER(1)      NOT NULL
);

CREATE TABLE ORG15_CheckResult (
    CheckResultKey   NUMBER(1)     NOT NULL,
    CheckResultName  VARCHAR2(30)  NOT NULL
);

CREATE TABLE ORG15_ReportDevice (
    ReportDeviceKey       NUMBER(9)  NOT NULL,
    RecruitmentReportKey  NUMBER(9)  NOT NULL,
    DeviceFingerprintKey  NUMBER(9)  NOT NULL
);

CREATE TABLE ORG15_DeviceFingerprint (
    DeviceFingerprintKey  NUMBER(9)     NOT NULL,
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

COMMENT ON TABLE ORG15_ReportVerdict IS 'Ocena zgłoszenia – każda ponowna ocena to nowy wiersz, aktualna jest jedna.';
COMMENT ON COLUMN ORG15_ReportVerdict.ReportVerdictKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_ReportVerdict.RecruitmentReportKey IS 'Zgłoszenie';
COMMENT ON COLUMN ORG15_ReportVerdict.VerdictDecisionKey IS 'Decyzja';
COMMENT ON COLUMN ORG15_ReportVerdict.VerdictRuleSetKey IS 'Według której wersji reguł';
COMMENT ON COLUMN ORG15_ReportVerdict.ReportWeight IS 'Waga od 0 do 1';
COMMENT ON COLUMN ORG15_ReportVerdict.DecidedAt IS 'Kiedy oceniono';
COMMENT ON COLUMN ORG15_ReportVerdict.IsCurrent IS '1 = ocena aktualna';
COMMENT ON COLUMN ORG15_ReportVerdict.SystemUserKey IS 'Kto ocenił (puste = program)';

COMMENT ON TABLE ORG15_VerdictRuleSet IS 'Wersja reguł oceny zgłoszeń – wybierana z listy; aktualna jest jedna.';
COMMENT ON COLUMN ORG15_VerdictRuleSet.VerdictRuleSetKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG15_VerdictRuleSet.VersionLabel IS 'Wersja, np. 1.0';
COMMENT ON COLUMN ORG15_VerdictRuleSet.RuleDescription IS 'Co mówią reguły';
COMMENT ON COLUMN ORG15_VerdictRuleSet.ValidFrom IS 'Od kiedy obowiązują';
COMMENT ON COLUMN ORG15_VerdictRuleSet.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG15_VerdictRuleSet.IsCurrent IS '1 = reguły używane teraz';

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
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_CK1 CHECK (ReportWeight BETWEEN 0 AND 1);
ALTER TABLE ORG15_VerdictRuleSet ADD CONSTRAINT ORG15_VerdictRuleSet_PK PRIMARY KEY (VerdictRuleSetKey);
ALTER TABLE ORG15_VerdictRuleSet ADD CONSTRAINT ORG15_VerdictRuleSet_VersionLabel_UN UNIQUE (VersionLabel);
ALTER TABLE ORG15_VerdictRuleSet ADD CONSTRAINT ORG15_VerdictRuleSet_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG15_VerdictRuleSet ADD CONSTRAINT ORG15_VerdictRuleSet_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG15_VerdictRuleSet ADD CONSTRAINT ORG15_VerdictRuleSet_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG15_CheckResult ADD CONSTRAINT ORG15_CheckResult_PK PRIMARY KEY (CheckResultKey);
ALTER TABLE ORG15_CheckResult ADD CONSTRAINT ORG15_CheckResult_CheckResultName_UN UNIQUE (CheckResultName);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_PK PRIMARY KEY (ReportDeviceKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_RecruitmentReportKey_UN UNIQUE (RecruitmentReportKey);
ALTER TABLE ORG15_DeviceFingerprint ADD CONSTRAINT ORG15_DeviceFingerprint_PK PRIMARY KEY (DeviceFingerprintKey);
ALTER TABLE ORG15_DeviceFingerprint ADD CONSTRAINT ORG15_DeviceFingerprint_FingerprintHash_UN UNIQUE (FingerprintHash);

ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_CheckType_FK FOREIGN KEY (CheckTypeKey) REFERENCES ORG15_CheckType (CheckTypeKey);
ALTER TABLE ORG15_ReportCheck ADD CONSTRAINT ORG15_ReportCheck_CheckResult_FK FOREIGN KEY (CheckResultKey) REFERENCES ORG15_CheckResult (CheckResultKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_VerdictDecision_FK FOREIGN KEY (VerdictDecisionKey) REFERENCES ORG15_VerdictDecision (VerdictDecisionKey);
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_VerdictRuleSet_FK FOREIGN KEY (VerdictRuleSetKey) REFERENCES ORG15_VerdictRuleSet (VerdictRuleSetKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_DeviceFingerprint_FK FOREIGN KEY (DeviceFingerprintKey) REFERENCES ORG15_DeviceFingerprint (DeviceFingerprintKey);

-- Organizm 16: Wykrywanie nadużyć
-- Wzorce wielu podejrzanych zgłoszeń naraz – podejrzenie, które potwierdza albo odrzuca człowiek.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
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
    AbuseAlertKey  NUMBER(7)  NOT NULL,
    EmployerKey    NUMBER(7)  NOT NULL,
    AlertTypeKey   NUMBER(2)  NOT NULL,
    WindowStart    TIMESTAMP  NOT NULL,
    WindowEnd      TIMESTAMP  NOT NULL,
    DetectedAt     TIMESTAMP  NOT NULL,
    ReportCount    NUMBER(6)  NOT NULL
);

CREATE TABLE ORG16_AlertStatusChange (
    AlertStatusChangeKey  NUMBER(7)      NOT NULL,
    AbuseAlertKey         NUMBER(7)      NOT NULL,
    AlertStatusKey        NUMBER(2)      NOT NULL,
    ChangedAt             TIMESTAMP      NOT NULL,
    ChangeComment         VARCHAR2(300),
    SystemUserKey         NUMBER(7),
    IsCurrent             NUMBER(1)      NOT NULL
);

CREATE TABLE ORG16_AlertReport (
    AlertReportKey        NUMBER(8)  NOT NULL,
    AbuseAlertKey         NUMBER(7)  NOT NULL,
    RecruitmentReportKey  NUMBER(9)  NOT NULL
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
COMMENT ON COLUMN ORG16_AbuseAlert.WindowStart IS 'Początek okresu fali';
COMMENT ON COLUMN ORG16_AbuseAlert.WindowEnd IS 'Koniec okresu fali';
COMMENT ON COLUMN ORG16_AbuseAlert.DetectedAt IS 'Kiedy wykryto';
COMMENT ON COLUMN ORG16_AbuseAlert.ReportCount IS 'Ile zgłoszeń w fali';

COMMENT ON TABLE ORG16_AlertStatusChange IS 'Zmiana stanu alertu – historia z autorem; aktualny stan jest jeden.';
COMMENT ON COLUMN ORG16_AlertStatusChange.AlertStatusChangeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG16_AlertStatusChange.AbuseAlertKey IS 'Alert';
COMMENT ON COLUMN ORG16_AlertStatusChange.AlertStatusKey IS 'Nowy stan';
COMMENT ON COLUMN ORG16_AlertStatusChange.ChangedAt IS 'Kiedy';
COMMENT ON COLUMN ORG16_AlertStatusChange.ChangeComment IS 'Uzasadnienie';
COMMENT ON COLUMN ORG16_AlertStatusChange.SystemUserKey IS 'Kto zmienił (puste = program)';
COMMENT ON COLUMN ORG16_AlertStatusChange.IsCurrent IS '1 = stan aktualny';

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
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_PK PRIMARY KEY (AlertStatusChangeKey);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_PK PRIMARY KEY (AlertReportKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_UN UNIQUE (AbuseAlertKey, RecruitmentReportKey);

ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_AlertType_FK FOREIGN KEY (AlertTypeKey) REFERENCES ORG16_AlertType (AlertTypeKey);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_AbuseAlert_FK FOREIGN KEY (AbuseAlertKey) REFERENCES ORG16_AbuseAlert (AbuseAlertKey);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_AlertStatus_FK FOREIGN KEY (AlertStatusKey) REFERENCES ORG16_AlertStatus (AlertStatusKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_AbuseAlert_FK FOREIGN KEY (AbuseAlertKey) REFERENCES ORG16_AbuseAlert (AbuseAlertKey);

-- Organizm 17: Sygnały o firmie
-- Liczby opisujące zachowanie firmy, policzone na dany dzień – wejście do Trust Score.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG17_SignalGroup (
    SignalGroupKey   NUMBER(2)     NOT NULL,
    SignalGroupName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG17_SignalSnapshot (
    SignalSnapshotKey  NUMBER(10)  NOT NULL,
    EmployerKey        NUMBER(7)   NOT NULL,
    SnapshotDate       DATE        NOT NULL
);

CREATE TABLE ORG17_SignalValue (
    SignalValueKey      NUMBER(11)    NOT NULL,
    SignalSnapshotKey   NUMBER(10)    NOT NULL,
    SignalTypeKey       NUMBER(3)     NOT NULL,
    SignalNumericValue  NUMBER(12,4)  NOT NULL,
    BasedOnCount        NUMBER(7)
);

CREATE TABLE ORG17_SignalType (
    SignalTypeKey      NUMBER(3)      NOT NULL,
    SignalTypeName     VARCHAR2(80)   NOT NULL,
    SignalGroupKey     NUMBER(2)      NOT NULL,
    MeasureUnitKey     NUMBER(2)      NOT NULL,
    HigherIsBetter     NUMBER(1)      NOT NULL,
    SignalDescription  VARCHAR2(300)
);

CREATE TABLE ORG17_MeasureUnit (
    MeasureUnitKey     NUMBER(2)     NOT NULL,
    MeasureUnitName    VARCHAR2(40)  NOT NULL,
    MeasureUnitSymbol  VARCHAR2(10)
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
COMMENT ON COLUMN ORG17_SignalType.MeasureUnitKey IS 'Jednostka';
COMMENT ON COLUMN ORG17_SignalType.HigherIsBetter IS '1 = im więcej, tym lepiej dla firmy';
COMMENT ON COLUMN ORG17_SignalType.SignalDescription IS 'Jak liczymy';

COMMENT ON TABLE ORG17_MeasureUnit IS 'Jednostka sygnału – wybierana z listy, a nie wpisywana.';
COMMENT ON COLUMN ORG17_MeasureUnit.MeasureUnitKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG17_MeasureUnit.MeasureUnitName IS 'Nazwa jednostki';
COMMENT ON COLUMN ORG17_MeasureUnit.MeasureUnitSymbol IS 'Skrót pokazywany przy wartości, np. %';

ALTER TABLE ORG17_SignalGroup ADD CONSTRAINT ORG17_SignalGroup_PK PRIMARY KEY (SignalGroupKey);
ALTER TABLE ORG17_SignalGroup ADD CONSTRAINT ORG17_SignalGroup_SignalGroupName_UN UNIQUE (SignalGroupName);
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_PK PRIMARY KEY (SignalSnapshotKey);
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_UN UNIQUE (EmployerKey, SnapshotDate);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_PK PRIMARY KEY (SignalValueKey);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_UN UNIQUE (SignalSnapshotKey, SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_PK PRIMARY KEY (SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_SignalTypeName_UN UNIQUE (SignalTypeName);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_HigherIsBetter_CK CHECK (HigherIsBetter IN (0, 1));
ALTER TABLE ORG17_MeasureUnit ADD CONSTRAINT ORG17_MeasureUnit_PK PRIMARY KEY (MeasureUnitKey);
ALTER TABLE ORG17_MeasureUnit ADD CONSTRAINT ORG17_MeasureUnit_MeasureUnitName_UN UNIQUE (MeasureUnitName);

ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES ORG17_SignalSnapshot (SignalSnapshotKey);
ALTER TABLE ORG17_SignalValue ADD CONSTRAINT ORG17_SignalValue_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_SignalGroup_FK FOREIGN KEY (SignalGroupKey) REFERENCES ORG17_SignalGroup (SignalGroupKey);
ALTER TABLE ORG17_SignalType ADD CONSTRAINT ORG17_SignalType_MeasureUnit_FK FOREIGN KEY (MeasureUnitKey) REFERENCES ORG17_MeasureUnit (MeasureUnitKey);

-- Organizm 18: Trust Score i publikacja
-- Wynik firmy policzony konkretną metodą, z pewnością i powodami – oraz to, co wolno pokazać kandydatowi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG18_ScoringMethodType (
    ScoringMethodTypeKey   NUMBER(1)     NOT NULL,
    ScoringMethodTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE ORG18_ScoringMethod (
    ScoringMethodKey      NUMBER(3)     NOT NULL,
    ScoringMethodTypeKey  NUMBER(1)     NOT NULL,
    MethodVersion         VARCHAR2(20)  NOT NULL,
    ValidFrom             DATE          NOT NULL,
    ValidTo               DATE,
    IsCurrent             NUMBER(1)     NOT NULL
);

CREATE TABLE ORG18_ScoringWeight (
    ScoringWeightKey  NUMBER(5)    NOT NULL,
    ScoringMethodKey  NUMBER(3)    NOT NULL,
    SignalTypeKey     NUMBER(3)    NOT NULL,
    WeightValue       NUMBER(5,3)  NOT NULL
);

CREATE TABLE ORG18_TrustScore (
    TrustScoreKey      NUMBER(10)   NOT NULL,
    SignalSnapshotKey  NUMBER(10)   NOT NULL,
    ScoringMethodKey   NUMBER(3)    NOT NULL,
    ScoreValue         NUMBER(3)    NOT NULL,
    ScoreConfidence    NUMBER(3,2)  NOT NULL,
    CalculatedAt       TIMESTAMP    NOT NULL
);

CREATE TABLE ORG18_ScoreReason (
    ScoreReasonKey  NUMBER(10)     NOT NULL,
    TrustScoreKey   NUMBER(10)     NOT NULL,
    SignalTypeKey   NUMBER(3)      NOT NULL,
    ReasonRank      NUMBER(1)      NOT NULL,
    ReasonText      VARCHAR2(300)  NOT NULL
);

CREATE TABLE ORG18_PublishedScore (
    PublishedScoreKey     NUMBER(9)   NOT NULL,
    EmployerKey           NUMBER(7)   NOT NULL,
    TrustScoreKey         NUMBER(10)  NOT NULL,
    PublicationStatusKey  NUMBER(2)   NOT NULL,
    PublishedFrom         TIMESTAMP   NOT NULL,
    PublishedTo           TIMESTAMP,
    IsCurrent             NUMBER(1)   NOT NULL
);

CREATE TABLE ORG18_PublicationStatus (
    PublicationStatusKey   NUMBER(2)     NOT NULL,
    PublicationStatusName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE ORG18_ScoringMethodType IS 'Rodzaj metody liczenia wyniku.';
COMMENT ON COLUMN ORG18_ScoringMethodType.ScoringMethodTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringMethodType.ScoringMethodTypeName IS 'Nazwa rodzaju metody';

COMMENT ON TABLE ORG18_ScoringMethod IS 'Metoda liczenia wyniku w konkretnej wersji; używana teraz jest jedna.';
COMMENT ON COLUMN ORG18_ScoringMethod.ScoringMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_ScoringMethod.ScoringMethodTypeKey IS 'Rodzaj metody';
COMMENT ON COLUMN ORG18_ScoringMethod.MethodVersion IS 'Wersja';
COMMENT ON COLUMN ORG18_ScoringMethod.ValidFrom IS 'Od kiedy używana';
COMMENT ON COLUMN ORG18_ScoringMethod.ValidTo IS 'Do kiedy (puste = obecna)';
COMMENT ON COLUMN ORG18_ScoringMethod.IsCurrent IS '1 = metoda używana teraz';

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

COMMENT ON TABLE ORG18_PublishedScore IS 'Wynik pokazany publicznie – osobno od wyniku roboczego; dla firmy aktualna jest jedna publikacja.';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedScoreKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_PublishedScore.EmployerKey IS 'Której firmy dotyczy';
COMMENT ON COLUMN ORG18_PublishedScore.TrustScoreKey IS 'Który wynik pokazujemy';
COMMENT ON COLUMN ORG18_PublishedScore.PublicationStatusKey IS 'Stan publikacji';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG18_PublishedScore.PublishedTo IS 'Do kiedy (puste = widoczny teraz)';
COMMENT ON COLUMN ORG18_PublishedScore.IsCurrent IS '1 = publikacja aktualna';

COMMENT ON TABLE ORG18_PublicationStatus IS 'Stan publikacji wyniku.';
COMMENT ON COLUMN ORG18_PublicationStatus.PublicationStatusKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG18_PublicationStatus.PublicationStatusName IS 'Nazwa stanu publikacji';

ALTER TABLE ORG18_ScoringMethodType ADD CONSTRAINT ORG18_ScoringMethodType_PK PRIMARY KEY (ScoringMethodTypeKey);
ALTER TABLE ORG18_ScoringMethodType ADD CONSTRAINT ORG18_ScoringMethodType_ScoringMethodTypeName_UN UNIQUE (ScoringMethodTypeName);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_PK PRIMARY KEY (ScoringMethodKey);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_UN UNIQUE (ScoringMethodTypeKey, MethodVersion);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_PK PRIMARY KEY (ScoringWeightKey);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_UN UNIQUE (ScoringMethodKey, SignalTypeKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_PK PRIMARY KEY (TrustScoreKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_CK1 CHECK (ScoreValue BETWEEN 0 AND 100);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_CK2 CHECK (ScoreConfidence BETWEEN 0 AND 1);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_PK PRIMARY KEY (ScoreReasonKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_UN UNIQUE (TrustScoreKey, ReasonRank);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_PK PRIMARY KEY (PublishedScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_CK1 CHECK (PublishedTo IS NULL OR PublishedTo >= PublishedFrom);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_CK2 CHECK (IsCurrent = 1 OR PublishedTo IS NOT NULL);
ALTER TABLE ORG18_PublicationStatus ADD CONSTRAINT ORG18_PublicationStatus_PK PRIMARY KEY (PublicationStatusKey);
ALTER TABLE ORG18_PublicationStatus ADD CONSTRAINT ORG18_PublicationStatus_PublicationStatusName_UN UNIQUE (PublicationStatusName);

ALTER TABLE ORG18_ScoringMethod ADD CONSTRAINT ORG18_ScoringMethod_ScoringMethodType_FK FOREIGN KEY (ScoringMethodTypeKey) REFERENCES ORG18_ScoringMethodType (ScoringMethodTypeKey);
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ORG18_ScoringMethod (ScoringMethodKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_ScoringMethod_FK FOREIGN KEY (ScoringMethodKey) REFERENCES ORG18_ScoringMethod (ScoringMethodKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES ORG18_TrustScore (TrustScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_TrustScore_FK FOREIGN KEY (TrustScoreKey) REFERENCES ORG18_TrustScore (TrustScoreKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_PublicationStatus_FK FOREIGN KEY (PublicationStatusKey) REFERENCES ORG18_PublicationStatus (PublicationStatusKey);

-- Organizm 19: Użytkownicy systemu i role
-- Kto pracuje w systemie: konta użytkowników, ich role i firmy, które reprezentują – z historią.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Wersja do Oracle SQL Developer Data Modeler (File → Import → DDL File): bez przykładowych wierszy
-- i bez indeksów warunkowych (nie są potrzebne do diagramu).
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE ORG19_Role (
    RoleKey          NUMBER(2)      NOT NULL,
    RoleName         VARCHAR2(40)   NOT NULL,
    RoleDescription  VARCHAR2(200)  NOT NULL
);

CREATE TABLE ORG19_UserRole (
    UserRoleKey    NUMBER(7)  NOT NULL,
    SystemUserKey  NUMBER(7)  NOT NULL,
    RoleKey        NUMBER(2)  NOT NULL,
    ValidFrom      DATE       NOT NULL,
    ValidTo        DATE,
    IsCurrent      NUMBER(1)  NOT NULL
);

CREATE TABLE ORG19_SystemUser (
    SystemUserKey  NUMBER(7)      NOT NULL,
    UserLogin      VARCHAR2(100)  NOT NULL,
    DisplayName    VARCHAR2(100)  NOT NULL,
    PasswordHash   VARCHAR2(100),
    CreatedAt      TIMESTAMP      NOT NULL,
    IsActive       NUMBER(1)      NOT NULL,
    DeactivatedAt  TIMESTAMP
);

CREATE TABLE ORG19_EmployerRepresentative (
    EmployerRepresentativeKey  NUMBER(7)  NOT NULL,
    SystemUserKey              NUMBER(7)  NOT NULL,
    EmployerKey                NUMBER(7)  NOT NULL,
    ValidFrom                  DATE       NOT NULL,
    ValidTo                    DATE,
    IsCurrent                  NUMBER(1)  NOT NULL,
    VerifiedAt                 TIMESTAMP
);

COMMENT ON TABLE ORG19_Role IS 'Rola użytkownika – decyduje, co wolno mu robić w systemie.';
COMMENT ON COLUMN ORG19_Role.RoleKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG19_Role.RoleName IS 'Nazwa roli';
COMMENT ON COLUMN ORG19_Role.RoleDescription IS 'Co wolno tej roli';

COMMENT ON TABLE ORG19_UserRole IS 'Rola użytkownika – przypisanie w czasie; jedna osoba ma kilka ról.';
COMMENT ON COLUMN ORG19_UserRole.UserRoleKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG19_UserRole.SystemUserKey IS 'Użytkownik';
COMMENT ON COLUMN ORG19_UserRole.RoleKey IS 'Rola';
COMMENT ON COLUMN ORG19_UserRole.ValidFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG19_UserRole.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG19_UserRole.IsCurrent IS '1 = rola aktualna';

COMMENT ON TABLE ORG19_SystemUser IS 'Konto osoby, która loguje się do systemu – personel albo przedstawiciel firmy.';
COMMENT ON COLUMN ORG19_SystemUser.SystemUserKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG19_SystemUser.UserLogin IS 'Login, np. służbowy adres e-mail';
COMMENT ON COLUMN ORG19_SystemUser.DisplayName IS 'Imię i nazwisko albo nazwa wyświetlana';
COMMENT ON COLUMN ORG19_SystemUser.PasswordHash IS 'Skrót hasła (np. bcrypt) – nigdy samo hasło; puste przy logowaniu przez zewnętrzny system';
COMMENT ON COLUMN ORG19_SystemUser.CreatedAt IS 'Kiedy założono konto';
COMMENT ON COLUMN ORG19_SystemUser.IsActive IS '1 = konto aktywne, 0 = wyłączone';
COMMENT ON COLUMN ORG19_SystemUser.DeactivatedAt IS 'Kiedy wyłączono (puste = aktywne)';

COMMENT ON TABLE ORG19_EmployerRepresentative IS 'Przedstawiciel firmy – przypisanie w czasie użytkownika do firmy.';
COMMENT ON COLUMN ORG19_EmployerRepresentative.EmployerRepresentativeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ORG19_EmployerRepresentative.SystemUserKey IS 'Użytkownik';
COMMENT ON COLUMN ORG19_EmployerRepresentative.EmployerKey IS 'Firma, którą reprezentuje';
COMMENT ON COLUMN ORG19_EmployerRepresentative.ValidFrom IS 'Od kiedy';
COMMENT ON COLUMN ORG19_EmployerRepresentative.ValidTo IS 'Do kiedy (puste = nadal)';
COMMENT ON COLUMN ORG19_EmployerRepresentative.IsCurrent IS '1 = reprezentuje teraz';
COMMENT ON COLUMN ORG19_EmployerRepresentative.VerifiedAt IS 'Kiedy potwierdziliśmy, że ta osoba reprezentuje firmę';

ALTER TABLE ORG19_Role ADD CONSTRAINT ORG19_Role_PK PRIMARY KEY (RoleKey);
ALTER TABLE ORG19_Role ADD CONSTRAINT ORG19_Role_RoleName_UN UNIQUE (RoleName);
ALTER TABLE ORG19_UserRole ADD CONSTRAINT ORG19_UserRole_PK PRIMARY KEY (UserRoleKey);
ALTER TABLE ORG19_UserRole ADD CONSTRAINT ORG19_UserRole_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG19_UserRole ADD CONSTRAINT ORG19_UserRole_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG19_UserRole ADD CONSTRAINT ORG19_UserRole_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);
ALTER TABLE ORG19_SystemUser ADD CONSTRAINT ORG19_SystemUser_PK PRIMARY KEY (SystemUserKey);
ALTER TABLE ORG19_SystemUser ADD CONSTRAINT ORG19_SystemUser_UserLogin_UN UNIQUE (UserLogin);
ALTER TABLE ORG19_SystemUser ADD CONSTRAINT ORG19_SystemUser_IsActive_CK CHECK (IsActive IN (0, 1));
ALTER TABLE ORG19_SystemUser ADD CONSTRAINT ORG19_SystemUser_CK1 CHECK (DeactivatedAt IS NULL OR DeactivatedAt >= CreatedAt);
ALTER TABLE ORG19_SystemUser ADD CONSTRAINT ORG19_SystemUser_CK2 CHECK (IsActive = 1 OR DeactivatedAt IS NOT NULL);
ALTER TABLE ORG19_EmployerRepresentative ADD CONSTRAINT ORG19_EmployerRepresentative_PK PRIMARY KEY (EmployerRepresentativeKey);
ALTER TABLE ORG19_EmployerRepresentative ADD CONSTRAINT ORG19_EmployerRepresentative_IsCurrent_CK CHECK (IsCurrent IN (0, 1));
ALTER TABLE ORG19_EmployerRepresentative ADD CONSTRAINT ORG19_EmployerRepresentative_CK1 CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom);
ALTER TABLE ORG19_EmployerRepresentative ADD CONSTRAINT ORG19_EmployerRepresentative_CK2 CHECK (IsCurrent = 1 OR ValidTo IS NOT NULL);

ALTER TABLE ORG19_UserRole ADD CONSTRAINT ORG19_UserRole_SystemUser_FK FOREIGN KEY (SystemUserKey) REFERENCES ORG19_SystemUser (SystemUserKey);
ALTER TABLE ORG19_UserRole ADD CONSTRAINT ORG19_UserRole_Role_FK FOREIGN KEY (RoleKey) REFERENCES ORG19_Role (RoleKey);
ALTER TABLE ORG19_EmployerRepresentative ADD CONSTRAINT ORG19_EmployerRepresentative_SystemUser_FK FOREIGN KEY (SystemUserKey) REFERENCES ORG19_SystemUser (SystemUserKey);

-- Połączenia między organizmami: klucze obce do tabel z innych organizmów.
-- Uruchom po plikach 01–18. Wygenerowane z narzedzia/organizmy.py.

-- organizm 4: Odbiór danych z platformy
ALTER TABLE ORG04_DataDelivery ADD CONSTRAINT ORG04_DataDelivery_APIEndpoint_FK FOREIGN KEY (APIEndpointKey) REFERENCES ORG01_APIEndpoint (APIEndpointKey);

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
ALTER TABLE ORG07_LinkChange ADD CONSTRAINT ORG07_LinkChange_SystemUser_FK FOREIGN KEY (SystemUserKey) REFERENCES ORG19_SystemUser (SystemUserKey);

-- organizm 8: Ogłoszenie i miejsce pracy
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_EmployerAccount_FK FOREIGN KEY (EmployerAccountKey) REFERENCES ORG05_EmployerAccount (EmployerAccountKey);
ALTER TABLE ORG08_JobPosting ADD CONSTRAINT ORG08_JobPosting_RawRecord_FK FOREIGN KEY (RawRecordKey) REFERENCES ORG04_RawRecord (RawRecordKey);
ALTER TABLE ORG08_Location ADD CONSTRAINT ORG08_Location_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);
ALTER TABLE ORG08_Region ADD CONSTRAINT ORG08_Region_Country_FK FOREIGN KEY (CountryKey) REFERENCES ORG01_Country (CountryKey);

-- organizm 9: Warunki zatrudnienia
ALTER TABLE ORG09_PostingSalary ADD CONSTRAINT ORG09_PostingSalary_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG09_PostingBenefit ADD CONSTRAINT ORG09_PostingBenefit_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);

-- organizm 10: Wymagania i obowiązki
ALTER TABLE ORG10_PostingResponsibility ADD CONSTRAINT ORG10_PostingResponsibility_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG10_PostingRequirement ADD CONSTRAINT ORG10_PostingRequirement_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);

-- organizm 11: Historia i treść ogłoszenia
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_JobPosting_FK FOREIGN KEY (JobPostingKey) REFERENCES ORG08_JobPosting (JobPostingKey);
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_DataDelivery_FK FOREIGN KEY (DataDeliveryKey) REFERENCES ORG04_DataDelivery (DataDeliveryKey);
ALTER TABLE ORG11_PostingEvent ADD CONSTRAINT ORG11_PostingEvent_SystemUser_FK FOREIGN KEY (SystemUserKey) REFERENCES ORG19_SystemUser (SystemUserKey);
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
ALTER TABLE ORG15_ReportVerdict ADD CONSTRAINT ORG15_ReportVerdict_SystemUser_FK FOREIGN KEY (SystemUserKey) REFERENCES ORG19_SystemUser (SystemUserKey);
ALTER TABLE ORG15_ReportDevice ADD CONSTRAINT ORG15_ReportDevice_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);

-- organizm 16: Wykrywanie nadużyć
ALTER TABLE ORG16_AbuseAlert ADD CONSTRAINT ORG16_AbuseAlert_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
ALTER TABLE ORG16_AlertStatusChange ADD CONSTRAINT ORG16_AlertStatusChange_SystemUser_FK FOREIGN KEY (SystemUserKey) REFERENCES ORG19_SystemUser (SystemUserKey);
ALTER TABLE ORG16_AlertReport ADD CONSTRAINT ORG16_AlertReport_RecruitmentReport_FK FOREIGN KEY (RecruitmentReportKey) REFERENCES ORG14_RecruitmentReport (RecruitmentReportKey);

-- organizm 17: Sygnały o firmie
ALTER TABLE ORG17_SignalSnapshot ADD CONSTRAINT ORG17_SignalSnapshot_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 18: Trust Score i publikacja
ALTER TABLE ORG18_ScoringWeight ADD CONSTRAINT ORG18_ScoringWeight_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
ALTER TABLE ORG18_TrustScore ADD CONSTRAINT ORG18_TrustScore_SignalSnapshot_FK FOREIGN KEY (SignalSnapshotKey) REFERENCES ORG17_SignalSnapshot (SignalSnapshotKey);
ALTER TABLE ORG18_ScoreReason ADD CONSTRAINT ORG18_ScoreReason_SignalType_FK FOREIGN KEY (SignalTypeKey) REFERENCES ORG17_SignalType (SignalTypeKey);
ALTER TABLE ORG18_PublishedScore ADD CONSTRAINT ORG18_PublishedScore_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);

-- organizm 19: Użytkownicy systemu i role
ALTER TABLE ORG19_EmployerRepresentative ADD CONSTRAINT ORG19_EmployerRepresentative_Employer_FK FOREIGN KEY (EmployerKey) REFERENCES ORG06_Employer (EmployerKey);
