-- Organizm 10: Wymagania i obowiązki
-- Czego firma oczekuje od kandydata i co ma on robić – rozpisane na pola, żeby dało się porównywać.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
-- Klucze obce do innych organizmów są w pliku 99_polaczenia_miedzy_organizmami.sql.

CREATE TABLE RequirementLevel (
    RequirementLevelKey   NUMBER(2)     NOT NULL,
    RequirementLevelName  VARCHAR2(20)  NOT NULL
);

CREATE TABLE PostingResponsibility (
    PostingResponsibilityKey  NUMBER(11)     NOT NULL,
    JobPostingKey             NUMBER(10)     NOT NULL,
    ResponsibilityText        VARCHAR2(400)  NOT NULL,
    ExtractionMethodKey       NUMBER(2)      NOT NULL
);

CREATE TABLE ProficiencyLevel (
    ProficiencyLevelKey   NUMBER(3)     NOT NULL,
    ProficiencyLevelName  VARCHAR2(40)  NOT NULL,
    SkillCategoryKey      NUMBER(2)     NOT NULL,
    ProficiencyRank       NUMBER(2)     NOT NULL
);

CREATE TABLE PostingRequirement (
    PostingRequirementKey  NUMBER(11)  NOT NULL,
    JobPostingKey          NUMBER(10)  NOT NULL,
    SkillKey               NUMBER(6)   NOT NULL,
    RequirementLevelKey    NUMBER(2)   NOT NULL,
    ProficiencyLevelKey    NUMBER(3),
    MinYearsExperience     NUMBER(2),
    ExtractionMethodKey    NUMBER(2)   NOT NULL
);

CREATE TABLE ExtractionMethod (
    ExtractionMethodKey   NUMBER(2)     NOT NULL,
    ExtractionMethodName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE SkillCategory (
    SkillCategoryKey   NUMBER(2)     NOT NULL,
    SkillCategoryName  VARCHAR2(40)  NOT NULL
);

CREATE TABLE Skill (
    SkillKey          NUMBER(6)     NOT NULL,
    SkillName         VARCHAR2(80)  NOT NULL,
    SkillCategoryKey  NUMBER(2)     NOT NULL
);

CREATE TABLE SkillSynonym (
    SkillSynonymKey  NUMBER(7)     NOT NULL,
    SkillKey         NUMBER(6)     NOT NULL,
    SynonymText      VARCHAR2(80)  NOT NULL
);

COMMENT ON TABLE RequirementLevel IS 'Ważność wymagania.';
COMMENT ON COLUMN RequirementLevel.RequirementLevelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN RequirementLevel.RequirementLevelName IS 'Nazwa ważności';

COMMENT ON TABLE PostingResponsibility IS 'Obowiązek opisany w ogłoszeniu.';
COMMENT ON COLUMN PostingResponsibility.PostingResponsibilityKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingResponsibility.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN PostingResponsibility.ResponsibilityText IS 'Treść obowiązku';
COMMENT ON COLUMN PostingResponsibility.ExtractionMethodKey IS 'Skąd wiemy';

COMMENT ON TABLE ProficiencyLevel IS 'Poziom znajomości – każda grupa umiejętności ma własną skalę.';
COMMENT ON COLUMN ProficiencyLevel.ProficiencyLevelKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ProficiencyLevel.ProficiencyLevelName IS 'Nazwa poziomu, np. B2';
COMMENT ON COLUMN ProficiencyLevel.SkillCategoryKey IS 'Dla jakiej grupy umiejętności';
COMMENT ON COLUMN ProficiencyLevel.ProficiencyRank IS 'Kolejność w skali (1 = najniższy)';

COMMENT ON TABLE PostingRequirement IS 'Wymaganie w ogłoszeniu.';
COMMENT ON COLUMN PostingRequirement.PostingRequirementKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN PostingRequirement.JobPostingKey IS 'Ogłoszenie';
COMMENT ON COLUMN PostingRequirement.SkillKey IS 'Umiejętność';
COMMENT ON COLUMN PostingRequirement.RequirementLevelKey IS 'Wymagane czy mile widziane';
COMMENT ON COLUMN PostingRequirement.ProficiencyLevelKey IS 'Poziom (bywa niepodany)';
COMMENT ON COLUMN PostingRequirement.MinYearsExperience IS 'Minimalne doświadczenie w latach';
COMMENT ON COLUMN PostingRequirement.ExtractionMethodKey IS 'Skąd wiemy';

COMMENT ON TABLE ExtractionMethod IS 'Skąd pochodzi informacja.';
COMMENT ON COLUMN ExtractionMethod.ExtractionMethodKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN ExtractionMethod.ExtractionMethodName IS 'Nazwa źródła informacji';

COMMENT ON TABLE SkillCategory IS 'Grupa umiejętności.';
COMMENT ON COLUMN SkillCategory.SkillCategoryKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SkillCategory.SkillCategoryName IS 'Nazwa grupy';

COMMENT ON TABLE Skill IS 'Umiejętność albo kwalifikacja.';
COMMENT ON COLUMN Skill.SkillKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN Skill.SkillName IS 'Nazwa';
COMMENT ON COLUMN Skill.SkillCategoryKey IS 'Grupa';

COMMENT ON TABLE SkillSynonym IS 'Inny zapis tej samej umiejętności.';
COMMENT ON COLUMN SkillSynonym.SkillSynonymKey IS 'Klucz główny – numer wiersza';
COMMENT ON COLUMN SkillSynonym.SkillKey IS 'Umiejętność';
COMMENT ON COLUMN SkillSynonym.SynonymText IS 'Zapis spotykany w ogłoszeniach';

ALTER TABLE RequirementLevel ADD CONSTRAINT RequirementLevel_PK PRIMARY KEY (RequirementLevelKey);
ALTER TABLE RequirementLevel ADD CONSTRAINT RequirementLevel_RequirementLevelName_UN UNIQUE (RequirementLevelName);
ALTER TABLE PostingResponsibility ADD CONSTRAINT PostingResponsibility_PK PRIMARY KEY (PostingResponsibilityKey);
ALTER TABLE ProficiencyLevel ADD CONSTRAINT ProficiencyLevel_PK PRIMARY KEY (ProficiencyLevelKey);
ALTER TABLE ProficiencyLevel ADD CONSTRAINT ProficiencyLevel_UN UNIQUE (SkillCategoryKey, ProficiencyLevelName);
ALTER TABLE PostingRequirement ADD CONSTRAINT PostingRequirement_PK PRIMARY KEY (PostingRequirementKey);
ALTER TABLE PostingRequirement ADD CONSTRAINT PostingRequirement_UN UNIQUE (JobPostingKey, SkillKey);
ALTER TABLE ExtractionMethod ADD CONSTRAINT ExtractionMethod_PK PRIMARY KEY (ExtractionMethodKey);
ALTER TABLE ExtractionMethod ADD CONSTRAINT ExtractionMethod_ExtractionMethodName_UN UNIQUE (ExtractionMethodName);
ALTER TABLE SkillCategory ADD CONSTRAINT SkillCategory_PK PRIMARY KEY (SkillCategoryKey);
ALTER TABLE SkillCategory ADD CONSTRAINT SkillCategory_SkillCategoryName_UN UNIQUE (SkillCategoryName);
ALTER TABLE Skill ADD CONSTRAINT Skill_PK PRIMARY KEY (SkillKey);
ALTER TABLE Skill ADD CONSTRAINT Skill_SkillName_UN UNIQUE (SkillName);
ALTER TABLE SkillSynonym ADD CONSTRAINT SkillSynonym_PK PRIMARY KEY (SkillSynonymKey);
ALTER TABLE SkillSynonym ADD CONSTRAINT SkillSynonym_SynonymText_UN UNIQUE (SynonymText);

ALTER TABLE PostingResponsibility ADD CONSTRAINT PostingResponsibility_ExtractionMethod_FK FOREIGN KEY (ExtractionMethodKey) REFERENCES ExtractionMethod (ExtractionMethodKey);
ALTER TABLE ProficiencyLevel ADD CONSTRAINT ProficiencyLevel_SkillCategory_FK FOREIGN KEY (SkillCategoryKey) REFERENCES SkillCategory (SkillCategoryKey);
ALTER TABLE PostingRequirement ADD CONSTRAINT PostingRequirement_Skill_FK FOREIGN KEY (SkillKey) REFERENCES Skill (SkillKey);
ALTER TABLE PostingRequirement ADD CONSTRAINT PostingRequirement_RequirementLevel_FK FOREIGN KEY (RequirementLevelKey) REFERENCES RequirementLevel (RequirementLevelKey);
ALTER TABLE PostingRequirement ADD CONSTRAINT PostingRequirement_ProficiencyLevel_FK FOREIGN KEY (ProficiencyLevelKey) REFERENCES ProficiencyLevel (ProficiencyLevelKey);
ALTER TABLE PostingRequirement ADD CONSTRAINT PostingRequirement_ExtractionMethod_FK FOREIGN KEY (ExtractionMethodKey) REFERENCES ExtractionMethod (ExtractionMethodKey);
ALTER TABLE Skill ADD CONSTRAINT Skill_SkillCategory_FK FOREIGN KEY (SkillCategoryKey) REFERENCES SkillCategory (SkillCategoryKey);
ALTER TABLE SkillSynonym ADD CONSTRAINT SkillSynonym_Skill_FK FOREIGN KEY (SkillKey) REFERENCES Skill (SkillKey);

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO RequirementLevel (RequirementLevelKey, RequirementLevelName) VALUES (1, 'Wymagane');
INSERT INTO RequirementLevel (RequirementLevelKey, RequirementLevelName) VALUES (2, 'Mile widziane');
INSERT INTO ExtractionMethod (ExtractionMethodKey, ExtractionMethodName) VALUES (1, 'Pole z API platformy');
INSERT INTO ExtractionMethod (ExtractionMethodKey, ExtractionMethodName) VALUES (2, 'Reguła tekstowa');
INSERT INTO ExtractionMethod (ExtractionMethodKey, ExtractionMethodName) VALUES (3, 'Model AI');
INSERT INTO ExtractionMethod (ExtractionMethodKey, ExtractionMethodName) VALUES (4, 'Wpisane ręcznie');
INSERT INTO SkillCategory (SkillCategoryKey, SkillCategoryName) VALUES (1, 'Technologia lub narzędzie');
INSERT INTO SkillCategory (SkillCategoryKey, SkillCategoryName) VALUES (2, 'Umiejętność miękka');
INSERT INTO SkillCategory (SkillCategoryKey, SkillCategoryName) VALUES (3, 'Język obcy');
INSERT INTO SkillCategory (SkillCategoryKey, SkillCategoryName) VALUES (4, 'Wykształcenie');
INSERT INTO SkillCategory (SkillCategoryKey, SkillCategoryName) VALUES (5, 'Certyfikat');
INSERT INTO SkillCategory (SkillCategoryKey, SkillCategoryName) VALUES (6, 'Uprawnienie');
INSERT INTO ProficiencyLevel (ProficiencyLevelKey, ProficiencyLevelName, SkillCategoryKey, ProficiencyRank) VALUES (1, 'A2', 3, 2);
INSERT INTO ProficiencyLevel (ProficiencyLevelKey, ProficiencyLevelName, SkillCategoryKey, ProficiencyRank) VALUES (2, 'B1', 3, 3);
INSERT INTO ProficiencyLevel (ProficiencyLevelKey, ProficiencyLevelName, SkillCategoryKey, ProficiencyRank) VALUES (3, 'B2', 3, 4);
INSERT INTO ProficiencyLevel (ProficiencyLevelKey, ProficiencyLevelName, SkillCategoryKey, ProficiencyRank) VALUES (4, 'C1', 3, 5);
INSERT INTO ProficiencyLevel (ProficiencyLevelKey, ProficiencyLevelName, SkillCategoryKey, ProficiencyRank) VALUES (5, 'Podstawowy', 1, 1);
INSERT INTO ProficiencyLevel (ProficiencyLevelKey, ProficiencyLevelName, SkillCategoryKey, ProficiencyRank) VALUES (6, 'Średniozaawansowany', 1, 2);
INSERT INTO ProficiencyLevel (ProficiencyLevelKey, ProficiencyLevelName, SkillCategoryKey, ProficiencyRank) VALUES (7, 'Zaawansowany', 1, 3);
INSERT INTO Skill (SkillKey, SkillName, SkillCategoryKey) VALUES (1, 'SQL', 1);
INSERT INTO Skill (SkillKey, SkillName, SkillCategoryKey) VALUES (2, 'Język angielski', 3);
INSERT INTO Skill (SkillKey, SkillName, SkillCategoryKey) VALUES (3, 'Komunikatywność', 2);
INSERT INTO Skill (SkillKey, SkillName, SkillCategoryKey) VALUES (4, 'Wykształcenie wyższe', 4);
INSERT INTO Skill (SkillKey, SkillName, SkillCategoryKey) VALUES (5, 'Prawo jazdy kat. B', 6);
INSERT INTO SkillSynonym (SkillSynonymKey, SkillKey, SynonymText) VALUES (1, 2, 'angielski');
INSERT INTO SkillSynonym (SkillSynonymKey, SkillKey, SynonymText) VALUES (2, 2, 'English');
INSERT INTO SkillSynonym (SkillSynonymKey, SkillKey, SynonymText) VALUES (3, 1, 'język SQL');
COMMIT;
