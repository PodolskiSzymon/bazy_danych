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
