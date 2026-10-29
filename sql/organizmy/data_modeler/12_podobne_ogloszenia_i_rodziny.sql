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
