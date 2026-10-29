-- Organizm 11: Historia i treść ogłoszenia
-- Co działo się z ogłoszeniem w czasie i jak zmieniała się jego treść.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE EventSource (
    EventSourceKey   NUMBER(2)     NOT NULL,
    EventSourceName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE PostingEventType (
    PostingEventTypeKey   NUMBER(2)     NOT NULL,
    PostingEventTypeName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE PostingEvent (
    PostingEventKey      NUMBER(12)  NOT NULL,
    JobPostingKey        NUMBER(10)  NOT NULL,
    PostingEventTypeKey  NUMBER(2)   NOT NULL,
    EventSourceKey       NUMBER(2)   NOT NULL,
    OccurredAt           TIMESTAMP   NOT NULL,
    DataDeliveryKey      NUMBER(10)
);

CREATE TABLE PostingVersion (
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

CREATE TABLE BoilerplatePattern (
    BoilerplatePatternKey  NUMBER(6)       NOT NULL,
    BoilerplateTypeKey     NUMBER(2)       NOT NULL,
    PatternText            VARCHAR2(1000)  NOT NULL,
    EmployerKey            NUMBER(8)
);

CREATE TABLE VersionBoilerplate (
    VersionBoilerplateKey  NUMBER(12)  NOT NULL,
    PostingVersionKey      NUMBER(11)  NOT NULL,
    BoilerplatePatternKey  NUMBER(6)   NOT NULL
);

CREATE TABLE BoilerplateType (
    BoilerplateTypeKey   NUMBER(2)     NOT NULL,
    BoilerplateTypeName  VARCHAR2(40)  NOT NULL
);

COMMENT ON TABLE EventSource IS 'Kto powiedział nam o zdarzeniu.';
COMMENT ON COLUMN EventSource.EventSourceKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN EventSource.EventSourceName IS 'Nazwa źródła zdarzenia';

COMMENT ON TABLE PostingEventType IS 'Rodzaj zdarzenia w życiu ogłoszenia.';
COMMENT ON COLUMN PostingEventType.PostingEventTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingEventType.PostingEventTypeName IS 'Nazwa zdarzenia';

COMMENT ON TABLE PostingEvent IS 'Zdarzenie w życiu ogłoszenia – tylko dopisujemy, nic nie zmieniamy.';
COMMENT ON COLUMN PostingEvent.PostingEventKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingEvent.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN PostingEvent.PostingEventTypeKey IS 'Co się stało';
COMMENT ON COLUMN PostingEvent.EventSourceKey IS 'Skąd wiemy';
COMMENT ON COLUMN PostingEvent.OccurredAt IS 'Kiedy';
COMMENT ON COLUMN PostingEvent.DataDeliveryKey IS 'W której dostawie przyszła informacja';

COMMENT ON TABLE PostingVersion IS 'Wersja treści ogłoszenia – każda edycja to nowy wiersz.';
COMMENT ON COLUMN PostingVersion.PostingVersionKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingVersion.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN PostingVersion.VersionNumber IS 'Numer wersji (1, 2, 3…)';
COMMENT ON COLUMN PostingVersion.VersionTitle IS 'Tytuł w tej wersji';
COMMENT ON COLUMN PostingVersion.OriginalText IS 'Treść tak, jak przyszła';
COMMENT ON COLUMN PostingVersion.CleanText IS 'Treść bez stopek i klauzul';
COMMENT ON COLUMN PostingVersion.TextHash IS 'Skrót treści – szybkie porównanie wersji';
COMMENT ON COLUMN PostingVersion.ValidFrom IS 'Od kiedy treść była taka';
COMMENT ON COLUMN PostingVersion.ValidTo IS 'Do kiedy (puste = aktualna)';

COMMENT ON TABLE BoilerplatePattern IS 'Powtarzalny fragment tekstu do rozpoznania w ogłoszeniach.';
COMMENT ON COLUMN BoilerplatePattern.BoilerplatePatternKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN BoilerplatePattern.BoilerplateTypeKey IS 'Rodzaj fragmentu';
COMMENT ON COLUMN BoilerplatePattern.PatternText IS 'Treść albo wzorzec fragmentu';
COMMENT ON COLUMN BoilerplatePattern.EmployerKey IS 'Firma, której to fragment (puste = wzorzec ogólny)';

COMMENT ON TABLE VersionBoilerplate IS 'Fragment znaleziony w wersji ogłoszenia – tabela łącząca.';
COMMENT ON COLUMN VersionBoilerplate.VersionBoilerplateKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN VersionBoilerplate.PostingVersionKey IS 'Wersja ogłoszenia';
COMMENT ON COLUMN VersionBoilerplate.BoilerplatePatternKey IS 'Znaleziony fragment';

COMMENT ON TABLE BoilerplateType IS 'Rodzaj powtarzalnego fragmentu.';
COMMENT ON COLUMN BoilerplateType.BoilerplateTypeKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN BoilerplateType.BoilerplateTypeName IS 'Nazwa rodzaju fragmentu';

ALTER TABLE EventSource ADD CONSTRAINT EventSource_PK PRIMARY KEY (EventSourceKey);
ALTER TABLE EventSource ADD CONSTRAINT EventSource_EventSourceName_UN UNIQUE (EventSourceName);
ALTER TABLE PostingEventType ADD CONSTRAINT PostingEventType_PK PRIMARY KEY (PostingEventTypeKey);
ALTER TABLE PostingEventType ADD CONSTRAINT PostingEventType_PostingEventTypeName_UN UNIQUE (PostingEventTypeName);
ALTER TABLE PostingEvent ADD CONSTRAINT PostingEvent_PK PRIMARY KEY (PostingEventKey);
ALTER TABLE PostingVersion ADD CONSTRAINT PostingVersion_PK PRIMARY KEY (PostingVersionKey);
ALTER TABLE PostingVersion ADD CONSTRAINT PostingVersion_UN UNIQUE (JobPostingKey, VersionNumber);
ALTER TABLE BoilerplatePattern ADD CONSTRAINT BoilerplatePattern_PK PRIMARY KEY (BoilerplatePatternKey);
ALTER TABLE VersionBoilerplate ADD CONSTRAINT VersionBoilerplate_PK PRIMARY KEY (VersionBoilerplateKey);
ALTER TABLE VersionBoilerplate ADD CONSTRAINT VersionBoilerplate_UN UNIQUE (PostingVersionKey, BoilerplatePatternKey);
ALTER TABLE BoilerplateType ADD CONSTRAINT BoilerplateType_PK PRIMARY KEY (BoilerplateTypeKey);
ALTER TABLE BoilerplateType ADD CONSTRAINT BoilerplateType_BoilerplateTypeName_UN UNIQUE (BoilerplateTypeName);

ALTER TABLE PostingEvent ADD CONSTRAINT PostingEvent_PostingEventType_FK FOREIGN KEY (PostingEventTypeKey) REFERENCES PostingEventType (PostingEventTypeKey);
ALTER TABLE PostingEvent ADD CONSTRAINT PostingEvent_EventSource_FK FOREIGN KEY (EventSourceKey) REFERENCES EventSource (EventSourceKey);
ALTER TABLE BoilerplatePattern ADD CONSTRAINT BoilerplatePattern_BoilerplateType_FK FOREIGN KEY (BoilerplateTypeKey) REFERENCES BoilerplateType (BoilerplateTypeKey);
ALTER TABLE VersionBoilerplate ADD CONSTRAINT VersionBoilerplate_PostingVersion_FK FOREIGN KEY (PostingVersionKey) REFERENCES PostingVersion (PostingVersionKey);
ALTER TABLE VersionBoilerplate ADD CONSTRAINT VersionBoilerplate_BoilerplatePattern_FK FOREIGN KEY (BoilerplatePatternKey) REFERENCES BoilerplatePattern (BoilerplatePatternKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO EventSource (EventSourceKey, EventSourceName) VALUES (1, 'Zgłoszone przez platformę');
INSERT INTO EventSource (EventSourceKey, EventSourceName) VALUES (2, 'Wykryte przez nas');
INSERT INTO EventSource (EventSourceKey, EventSourceName) VALUES (3, 'Wpisane przez moderatora');
INSERT INTO PostingEventType (PostingEventTypeKey, PostingEventTypeName) VALUES (1, 'Opublikowano');
INSERT INTO PostingEventType (PostingEventTypeKey, PostingEventTypeName) VALUES (2, 'Edytowano treść');
INSERT INTO PostingEventType (PostingEventTypeKey, PostingEventTypeName) VALUES (3, 'Odświeżono (podbito)');
INSERT INTO PostingEventType (PostingEventTypeKey, PostingEventTypeName) VALUES (4, 'Wygasło');
INSERT INTO PostingEventType (PostingEventTypeKey, PostingEventTypeName) VALUES (5, 'Zamknięto przed terminem');
INSERT INTO PostingEventType (PostingEventTypeKey, PostingEventTypeName) VALUES (6, 'Opublikowano ponownie');
INSERT INTO PostingEventType (PostingEventTypeKey, PostingEventTypeName) VALUES (7, 'Usunięto');
INSERT INTO BoilerplateType (BoilerplateTypeKey, BoilerplateTypeName) VALUES (1, 'Stopka „O nas”');
INSERT INTO BoilerplateType (BoilerplateTypeKey, BoilerplateTypeName) VALUES (2, 'Klauzula RODO');
INSERT INTO BoilerplateType (BoilerplateTypeKey, BoilerplateTypeName) VALUES (3, 'Zgoda na przyszłe rekrutacje');
INSERT INTO BoilerplateType (BoilerplateTypeKey, BoilerplateTypeName) VALUES (4, 'Formatowanie HTML');
COMMIT;
