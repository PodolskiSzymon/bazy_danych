-- Organizm 9: Warunki zatrudnienia
-- Na jakiej umowie, za ile i z jakimi dodatkami – obietnica, którą firma składa w ogłoszeniu.
-- Wygenerowane z narzedzia/organizmy.py (python narzedzia/build_web.py) – zmiany wprowadzaj tam.
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

-- Przykładowe wiersze: w słownikach to warianty, o które pytaliśmy („jakie mogą być warianty?”).
INSERT INTO ORG09_Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (1, 'PLN', 'złoty');
INSERT INTO ORG09_Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (2, 'EUR', 'euro');
INSERT INTO ORG09_Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (3, 'USD', 'dolar amerykański');
INSERT INTO ORG09_Currency (CurrencyKey, CurrencyCode, CurrencyName) VALUES (4, 'GBP', 'funt brytyjski');
INSERT INTO ORG09_ContractType (ContractTypeKey, ContractTypeName) VALUES (1, 'Umowa o pracę');
INSERT INTO ORG09_ContractType (ContractTypeKey, ContractTypeName) VALUES (2, 'Kontrakt B2B');
INSERT INTO ORG09_ContractType (ContractTypeKey, ContractTypeName) VALUES (3, 'Umowa zlecenie');
INSERT INTO ORG09_ContractType (ContractTypeKey, ContractTypeName) VALUES (4, 'Umowa o dzieło');
INSERT INTO ORG09_ContractType (ContractTypeKey, ContractTypeName) VALUES (5, 'Staż lub praktyki');
INSERT INTO ORG09_ContractType (ContractTypeKey, ContractTypeName) VALUES (6, 'Umowa na zastępstwo');
INSERT INTO ORG09_SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (1, 'Za godzinę');
INSERT INTO ORG09_SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (2, 'Miesięcznie');
INSERT INTO ORG09_SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (3, 'Rocznie');
INSERT INTO ORG09_SalaryPeriod (SalaryPeriodKey, SalaryPeriodName) VALUES (4, 'Za projekt');
INSERT INTO ORG09_BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (1, 'Zdrowie');
INSERT INTO ORG09_BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (2, 'Sport i rekreacja');
INSERT INTO ORG09_BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (3, 'Rozwój');
INSERT INTO ORG09_BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (4, 'Elastyczność');
INSERT INTO ORG09_BenefitCategory (BenefitCategoryKey, BenefitCategoryName) VALUES (5, 'Finanse');
INSERT INTO ORG09_Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (1, 'Prywatna opieka medyczna', 1);
INSERT INTO ORG09_Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (2, 'Karta sportowa', 2);
INSERT INTO ORG09_Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (3, 'Budżet szkoleniowy', 3);
INSERT INTO ORG09_Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (4, 'Elastyczne godziny pracy', 4);
INSERT INTO ORG09_Benefit (BenefitKey, BenefitName, BenefitCategoryKey) VALUES (5, 'Premia roczna', 5);
COMMIT;
