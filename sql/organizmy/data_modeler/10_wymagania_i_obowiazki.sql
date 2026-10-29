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
