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
