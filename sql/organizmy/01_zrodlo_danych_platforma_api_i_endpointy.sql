-- Organizm 1: Źródło danych: platforma, API i endpointy
-- Skąd i jak przychodzą dane: platforma, jej kanały API, wersje i endpointy – aż do pojedynczego pola w odpowiedzi.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
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

-- Unikalne tylko w części wierszy, np. jeden aktualny wiersz (unikalny indeks funkcyjny).
CREATE UNIQUE INDEX ORG01_PlatformClassification_UX ON ORG01_PlatformClassification (CASE WHEN IsMainType = 1 THEN SourcePlatformKey END);
CREATE UNIQUE INDEX ORG01_PlatformDomain_UX1 ON ORG01_PlatformDomain (CASE WHEN IsCurrent = 1 THEN DomainName END);
CREATE UNIQUE INDEX ORG01_PlatformDomain_UX2 ON ORG01_PlatformDomain (CASE WHEN IsCurrent = 1 AND IsMainDomain = 1 THEN SourcePlatformKey END);
CREATE UNIQUE INDEX ORG01_PlatformMarket_UX ON ORG01_PlatformMarket (CASE WHEN IsCurrent = 1 THEN SourcePlatformKey END, CASE WHEN IsCurrent = 1 THEN CountryKey END);
CREATE UNIQUE INDEX ORG01_PartnerAgreement_UX ON ORG01_PartnerAgreement (CASE WHEN IsCurrent = 1 THEN SourcePlatformKey END);
CREATE UNIQUE INDEX ORG01_APIVersion_UX ON ORG01_APIVersion (CASE WHEN IsInUse = 1 THEN PlatformAPIKey END);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG01_PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (1, 'Portal z ofertami pracy');
INSERT INTO ORG01_PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (2, 'Serwis ogłoszeń drobnych');
INSERT INTO ORG01_PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (3, 'Agregator ofert');
INSERT INTO ORG01_PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (4, 'Serwis społecznościowy');
INSERT INTO ORG01_PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (5, 'Publiczny urząd pracy');
INSERT INTO ORG01_PlatformType (PlatformTypeKey, PlatformTypeName) VALUES (6, 'Strona kariery firmy (ATS)');
INSERT INTO ORG01_SourcePlatform (SourcePlatformKey, SourcePlatformName, MainHomePage, AddedDate) VALUES (1, 'pracuj.pl', 'https://www.pracuj.pl', DATE '2026-10-01');
INSERT INTO ORG01_SourcePlatform (SourcePlatformKey, SourcePlatformName, MainHomePage, AddedDate) VALUES (2, 'OLX', 'https://www.olx.pl', DATE '2026-10-01');
INSERT INTO ORG01_PlatformClassification (PlatformClassificationKey, SourcePlatformKey, PlatformTypeKey, IsMainType) VALUES (1, 1, 1, 1);
INSERT INTO ORG01_PlatformClassification (PlatformClassificationKey, SourcePlatformKey, PlatformTypeKey, IsMainType) VALUES (2, 2, 2, 1);
INSERT INTO ORG01_PlatformClassification (PlatformClassificationKey, SourcePlatformKey, PlatformTypeKey, IsMainType) VALUES (3, 2, 1, 0);
INSERT INTO ORG01_Country (CountryKey, CountryCode, CountryName) VALUES (1, 'PL', 'Polska');
INSERT INTO ORG01_Country (CountryKey, CountryCode, CountryName) VALUES (2, 'DE', 'Niemcy');
INSERT INTO ORG01_Country (CountryKey, CountryCode, CountryName) VALUES (3, 'CZ', 'Czechy');
INSERT INTO ORG01_Country (CountryKey, CountryCode, CountryName) VALUES (4, 'RO', 'Rumunia');
INSERT INTO ORG01_Country (CountryKey, CountryCode, CountryName) VALUES (5, 'PT', 'Portugalia');
INSERT INTO ORG01_Country (CountryKey, CountryCode, CountryName) VALUES (6, 'UA', 'Ukraina');
INSERT INTO ORG01_AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (1, 'Negocjacje');
INSERT INTO ORG01_AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (2, 'Pilotaż');
INSERT INTO ORG01_AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (3, 'Aktywna');
INSERT INTO ORG01_AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (4, 'Zawieszona');
INSERT INTO ORG01_AgreementStatus (AgreementStatusKey, AgreementStatusName) VALUES (5, 'Rozwiązana');
INSERT INTO ORG01_APIType (APITypeKey, APITypeName) VALUES (1, 'REST');
INSERT INTO ORG01_APIType (APITypeKey, APITypeName) VALUES (2, 'GraphQL');
INSERT INTO ORG01_APIType (APITypeKey, APITypeName) VALUES (3, 'SOAP');
INSERT INTO ORG01_APIType (APITypeKey, APITypeName) VALUES (4, 'Webhook');
INSERT INTO ORG01_APIType (APITypeKey, APITypeName) VALUES (5, 'Eksport pliku');
INSERT INTO ORG01_APIType (APITypeKey, APITypeName) VALUES (6, 'Kanał RSS');
INSERT INTO ORG01_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (1, 'JSON', 'application/json');
INSERT INTO ORG01_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (2, 'XML', 'application/xml');
INSERT INTO ORG01_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (3, 'CSV', 'text/csv');
INSERT INTO ORG01_DataFormat (DataFormatKey, DataFormatName, MimeType) VALUES (4, 'HTML', 'text/html');
INSERT INTO ORG01_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (1, 'Klucz API');
INSERT INTO ORG01_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (2, 'OAuth 2.0');
INSERT INTO ORG01_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (3, 'Certyfikat klienta (mTLS)');
INSERT INTO ORG01_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (4, 'Podpis HMAC');
INSERT INTO ORG01_AuthMethod (AuthMethodKey, AuthMethodName) VALUES (5, 'Brak zabezpieczenia');
INSERT INTO ORG01_APIDirection (APIDirectionKey, APIDirectionName) VALUES (1, 'My pobieramy dane (pull)');
INSERT INTO ORG01_APIDirection (APIDirectionKey, APIDirectionName) VALUES (2, 'Platforma wysyła dane (push)');
INSERT INTO ORG01_EnvironmentType (EnvironmentTypeKey, EnvironmentTypeName) VALUES (1, 'Testowe (sandbox)');
INSERT INTO ORG01_EnvironmentType (EnvironmentTypeKey, EnvironmentTypeName) VALUES (2, 'Produkcyjne');
INSERT INTO ORG01_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (1, 'GET');
INSERT INTO ORG01_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (2, 'POST');
INSERT INTO ORG01_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (3, 'PUT');
INSERT INTO ORG01_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (4, 'PATCH');
INSERT INTO ORG01_HTTPMethod (HTTPMethodKey, HTTPMethodName) VALUES (5, 'DELETE');
INSERT INTO ORG01_DataSubject (DataSubjectKey, DataSubjectName) VALUES (1, 'Konto firmy');
INSERT INTO ORG01_DataSubject (DataSubjectKey, DataSubjectName) VALUES (2, 'Ogłoszenie');
INSERT INTO ORG01_DataSubject (DataSubjectKey, DataSubjectName) VALUES (3, 'Zdarzenie ogłoszenia');
INSERT INTO ORG01_DataSubject (DataSubjectKey, DataSubjectName) VALUES (4, 'Aplikacja kandydata');
INSERT INTO ORG01_DataSubject (DataSubjectKey, DataSubjectName) VALUES (5, 'Status aplikacji');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (1, 'Tekst');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (2, 'Liczba całkowita');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (3, 'Liczba dziesiętna');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (4, 'Prawda / fałsz');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (5, 'Data');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (6, 'Data i godzina');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (7, 'Lista');
INSERT INTO ORG01_FieldDataType (FieldDataTypeKey, FieldDataTypeName) VALUES (8, 'Obiekt');
INSERT INTO ORG01_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (1, 'Wynagrodzenie od', 2, 'Dolna granica widełek');
INSERT INTO ORG01_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (2, 'Rodzaj umowy', 2, NULL);
INSERT INTO ORG01_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (3, 'NIP firmy', 1, 'NIP wpisany w koncie firmy');
INSERT INTO ORG01_CanonicalField (CanonicalFieldKey, CanonicalFieldName, DataSubjectKey, CanonicalFieldDescription) VALUES (4, 'Data aplikacji', 4, NULL);
COMMIT;
