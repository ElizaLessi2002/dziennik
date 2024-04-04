/*
Projekt systemu

Zadanie polega na zbudowaniu systemu obs³uguj¹cego podan¹ instytucjê w oparciu o nastêpuj¹ce wytyczne:

Schemat bazy danych odzwierciedla wszystkie rzeczywiste atrybuty i zale¿noœci obiektów wystêpuj¹cych w ramach podanej tematyki.
Schemat bazy danych sk³ada siê z minimum 5 tabel.
Ka¿da tabela sk³ada siê z kolumn o zdefiniowanych typach i na³o¿onych odpowiednich ograniczeniach (constraint).
Pomiêdzy tabelami istniej¹ powi¹zania opieraj¹ce siê na kluczach podstawowych i obcych,
Poszczególne tabele wstêpnie uzupe³nione s¹ przyk³adowymi danymi z uwzglêdnieniem zró¿nicowania pomiêdzy poszczególnymi wyst¹pieniami tego samego obiektu.
Podgl¹d danych znajduj¹cych siê w bazie mo¿na uzyskaæ poprzez odpowiednie zapytania wybieraj¹ce – nale¿y uwzglêdniæ minimum 10 zapytañ, w ramach zapytañ nale¿y uwzglêdniæ funkcje agreguj¹ce, podzapytania.
Wprowadzanie, usuwanie i aktualizowanie danych odbywa siê poprzez odpowiednie polecenia SQL. 

Mo¿liwe instytucje / przedsiêbiorstwa
Przychodnia lekarska,
Szko³a (mo¿liwoœci: dziennik, kadry)
Oœrodek sportowy (wypo¿yczalnia sprzêtu, organizacja zajêæ sportowych, organizacja zawodów sportowych),
Oœrodek wypoczynkowy (hotel, spa, restauracja)

Oddana praca powinna zawieraæ opis projektu. */

if exists(select 1 from master.dbo.sysdatabases where name = 'Dziennik_elektr') drop database Dziennik_elektr
go
create database Dziennik_elektr
go
use Dziennik_elektr 

--drop database Dziennik_elektr


CREATE TABLE Plan_zajec 
	(
	id_plan INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	data_zjazdu DATE,
	wydarzenie VARCHAR(40),
	dzien VARCHAR(20) CONSTRAINT CHK_dzien CHECK(dzien IN('Poniedzialek','Wtorek','Sroda','Czwartek', 'Piatek', 'Sobota', 'Niedziela')),
	godz_pocz TIME,
	godz_kon TIME,
	tydzien INT CHECK(tydzien BETWEEN 1 AND 2),
	miesiac VARCHAR(100) CONSTRAINT CHK_miesiac CHECK(miesiac IN('Styczen','Luty','Marzec','Kwiecien','Maj','Czerwiec','Lipiec','Sierpien','Wrzesien','Pazdziernik', 'Listopad', 'Grudzien'))

	);

CREATE TABLE Profil
	(
	id_ucznia INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	imie VARCHAR(20),
	nazwisko VARCHAR(30),
	data_urodzenia DATE,
	miejsce_urodzenia VARCHAR(10),
	email VARCHAR(100),
	nr_telefonu CHAR(12),
	nr_indeksu INT,
	data_rekrutacji DATE,
	data_podpisania_umowy DATE,
	rok_studiow INT,
	semestr INT,
	system_studiow VARCHAR(40),
	specjalizacja VARCHAR(30),
	ios BIT,

	id_plan INT CONSTRAINT FK_id_plan REFERENCES Plan_zajec(id_plan)
	);




CREATE TABLE Dydaktycy
	(
	id_dyd INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	semestr INT,
	tytul_nauk VARCHAR(10) CONSTRAINT CHK_tytul_nauk CHECK(tytul_nauk IN('inz','mgr','dr hab','dr inz')),
	dydaktyk VARCHAR(20),
	email VARCHAR(100),
	tel CHAR(10),
	przedmiot VARCHAR(40),

	id_ucznia INT CONSTRAINT FK_id_ucznia REFERENCES Profil(id_ucznia)
	);


CREATE TABLE Egzaminy
	(
	id_egzamin INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	semestr INT,
	dydaktyk VARCHAR(20),
	system_egz VARCHAR(30) CONSTRAINT CHK_system_egz CHECK(system_egz IN('Licencjackie','Magisterskie','Inzynierskie')),
	tryb VARCHAR(20) CONSTRAINT CHK_tryb CHECK(tryb IN('zaoczny','eksternistyczny','dzienny')),
	kierunek VARCHAR(40) CONSTRAINT CHK_kierunek CHECK(kierunek IN('Informatyka','Grafika','Sztuczna inteligencja','Bazy danych','Cyberbezpieczeñstwo')),

	id_ucznia INT,
    FOREIGN KEY (id_ucznia) REFERENCES Profil(id_ucznia),
    
    id_dyd INT,
    FOREIGN KEY (id_dyd) REFERENCES Dydaktycy(id_dyd)
	);



CREATE TABLE Oceny 
	(
	id_oceny INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	przedmiot VARCHAR(40),
	forma VARCHAR(30) CONSTRAINT CHK_forma CHECK(forma IN('Cwiczenia','Laboratorium', 'Wyklad', 'Projekt', 'Praktyki zawodowe')),
	ocena_koncowa DECIMAL(6,1),
	zaliczony BIT,

	id_ucznia INT,
    FOREIGN KEY (id_ucznia) REFERENCES Profil(id_ucznia)
	);




CREATE TABLE Moje_finanse
	(
	id_finanse INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	stan_konta INT,
	konto_wplat DECIMAL(26,0),
	data_ostatniej_wplaty DATE,
	kwota_wplaty DECIMAL(10,2),
	typ_transakcji VARCHAR(30) CONSTRAINT CHK_typ_transakcji CHECK(typ_transakcji IN('przelew','gotowka')),
	opis_transakcji TEXT,
	data_zaksiegowania DATETIME,
	status_wplaty VARCHAR(20),

	id_ucznia INT,
    FOREIGN KEY (id_ucznia) REFERENCES Profil(id_ucznia)
	);


CREATE TABLE Tok_studiow
	(
	id_ts INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	data_rozp_st DATE,
	data_zak_st DATE,
	data_ts DATE,
	opis_ts VARCHAR(40) CONSTRAINT CHK_opis_ts CHECK(opis_ts IN('Rejestracja na semestr','Rozliczenie semestru','Przedluzenie sesji egzaminacyjnej','Wybor specjalizacji','Rekrutacja','Rozpoczecie systemu IOS','Zakonczenie systemu IOS','Zmiana grupy','Nadanie numeru indeksu')),
	
	id_ucznia INT,
    FOREIGN KEY (id_ucznia) REFERENCES Profil(id_ucznia)
	);

-- Plan_zajec
INSERT INTO Plan_zajec (data_zjazdu, wydarzenie, dzien, godz_pocz, godz_kon, tydzien, miesiac)
VALUES
    ('2024-01-10', 'Wyk³ad z cyberbezpieczeñstwa', 'Poniedzialek', '08:00', '10:00', 1, 'Styczen'),
    ('2024-01-11', 'Technologie webowe', 'Wtorek', '10:30', '12:30', 1, 'Styczen'),
    ('2024-01-12', 'Uczenie maszynowe', 'Sroda', '13:00', '15:00', 2, 'Styczen'),
    ('2024-01-13', 'Wyk³ad z baz danych', 'Czwartek', '09:00', '11:00', 2, 'Styczen'),
    ('2024-01-14', 'Laboratorium ze sztucznej inteligencji', 'Piatek', '14:30', '16:30', 1, 'Styczen'),
    ('2024-01-15', 'Wyk³ad z technologii XML', 'Sobota', '11:00', '13:00', 2, 'Styczen'),
    ('2024-01-16', 'Programowanie obiektowe', 'Niedziela', '10:00', '12:00', 2, 'Styczen'),
    ('2024-02-05', 'In¿ynieria oprogramowania', 'Poniedzialek', '09:30', '11:30', 1, 'Luty'),
    ('2024-02-06', 'Psychologia reklamy', 'Wtorek', '13:30', '15:30', 1, 'Luty'),
    ('2024-02-07', 'Historia grafiki', 'Sroda', '15:00', '17:00', 2, 'Luty'),
    ('2024-02-08', 'Big Data', 'Czwartek', '08:30', '10:30', 2, 'Luty'),
    ('2024-02-09', 'Strategia biznesowa i AI', 'Piatek', '12:00', '14:00', 1, 'Luty'),
    ('2024-02-10', 'Programowanie gier komputerowych', 'Sobota', '16:30', '18:30', 1, 'Luty'),
    ('2024-02-11', 'Komunikacja cz³owiek-komputer', 'Niedziela', '14:00', '16:00', 2, 'Luty'),
    ('2024-03-03', 'Podstawy hurtowni danych', 'Poniedzialek', '11:30', '13:30', 1, 'Marzec');

-- Profil
INSERT INTO Profil (imie, nazwisko, data_urodzenia, miejsce_urodzenia, email, nr_telefonu, nr_indeksu, data_rekrutacji, data_podpisania_umowy, rok_studiow, semestr, system_studiow, specjalizacja, ios, id_plan)
VALUES
    ('Jan', 'Kowalski', '1998-05-15', 'Warszawa', 'jan.kowalski@wp.com', '12345678901', 123456, '2022-09-01', '2022-09-05', 2, 1, 'Tradycyjny', 'Informatyka', 1,1),
    ('Anna', 'Nowak', '1999-08-21', 'Kraków', 'anna.nowak@gmail.com', '98765432109', 654321, '2023-01-15', '2023-01-20', 1, 2, 'Tradycyjny', 'Grafika', 0,2),
    ('Piotr', 'Zalewski', '1997-12-10', 'Gdañsk', 'piotr.zalewski@wp.pl', '55566677788', 987654, '2024-03-10', '2024-03-15', 3, 1, 'Online', 'Sztuczna Inteligencja', 1,3),
    ('Karolina', 'Lis', '2000-02-28', 'Poznañ', 'karolina.lis@gmail.com', '11122233344', 234567, '2025-06-05', '2025-06-10', 2, 2, 'Online', 'Bezpieczeñstwo Informatyczne', 0,4),
    ('Marcin', 'Wójcik', '1996-07-03', '£ódŸ', 'marcin.wojcik@gmail.com', '77788899900', 345678, '2023-09-01', '2023-09-05', 1, 1, 'Tradycyjny', 'Informatyka', 1,5),
    ('Katarzyna', 'Krawczyk', '1999-04-18', 'Katowice', 'katarzyna.krawczyk@wp.pl', '33344455566', 456789, '2024-02-01', '2024-02-05', 2, 1, 'Online', 'Projektowanie Stron WWW', 0,6),
    ('Adam', 'Szymañski', '1998-09-09', 'Wroc³aw', 'adam.szymanski@gmail.com', '22233344455', 567890, '2025-07-20', '2025-07-25', 3, 2, 'Tradycyjny', 'Bazy Danych', 1,7),
    ('Natalia', 'Duda', '1997-11-24', 'Szczecin', 'natalia.duda@wp.pl', '66677788899', 678901, '2024-12-01', '2024-12-05', 2, 2, 'Online', 'Sztuczna Inteligencja', 0,8),
    ('£ukasz', 'Kaczmarek', '2000-06-12', 'Gdynia', 'lukasz.kaczmarek@wp.pl', '44455566677', 789012, '2023-10-15', '2023-10-20', 1, 2, 'Tradycyjny', 'Grafika Komputerowa', 1,9),
    ('Aleksandra', 'Jaworska', '1999-01-30', 'Bia³ystok', 'aleksandra.jaworska@wp.pl', '99900011122', 890123, '2024-05-10', '2024-05-15', 2, 1, 'Online', 'Bezpieczeñstwo Informatyczne', 0,10),
    ('Robert', 'Michalak', '1996-04-09', 'Olsztyn', 'robert.michalak@gmail.com', '88899900011', 901234, '2023-03-01', '2023-03-05', 1, 1, 'Tradycyjny', 'Informatyka', 1,11),
    ('Monika', 'Witkowska', '1998-10-22', 'Rzeszów', 'monika.witkowska@wp.pl', '77788899900', 123789, '2025-01-10', '2025-01-15', 3, 1, 'Online', 'Sztuczna Inteligencja', 0,12),
    ('Kamil', 'Mazurek', '1997-02-14', 'Bydgoszcz', 'kamil.mazurek@wp.pl', '55566677788', 456789, '2023-11-05', '2023-11-10', 1, 2, 'Tradycyjny', 'Projektowanie Stron WWW', 1,13),
    ('Ewa', 'Kowalczyk', '2000-07-07', 'Lublin', 'ewa.kowalczyk@wp.pl', '33344455566', 789012, '2024-09-15', '2024-09-20', 2, 2, 'Online', 'Bazy Danych', 0,14),
    ('Tomasz', 'Szulc', '1999-03-01', 'Kielce', 'tomasz.szulc@gmail.com', '22233344455', 890123, '2023-08-01', '2023-08-05', 1, 1, 'Tradycyjny', 'Informatyka', 1,15);

--Dydaktycy
INSERT INTO Dydaktycy (semestr, tytul_nauk, dydaktyk, email, tel, przedmiot, id_ucznia)
VALUES
    (1, 'inz', 'Anna Nowak', 'anna.nowak@gmail.com', '1234567890', 'Technologie webowe',1),
    (2, 'mgr', 'Jan Kowalski', 'jan.kowalski@wp.pl', '9876543210', 'Strategia biznesowa i AI',2),
    (1, 'dr hab', 'Maria Lis', 'maria.lis@gmail.com', '5551112233', 'Bazy danych',3),
    (3, 'dr inz', 'Piotr Zaj¹c', 'piotr.zajac@gmail.com', '4442221111', 'Technologie XML',4),
    (2, 'inz', 'Tomasz Wójcik', 'tomasz.wojcik@gmail.com', '6667778888', 'In¿ynieria oprogramowania',5),
    (1, 'mgr', 'Alicja Kowalczyk', 'alicja.kowalczyk@wp.pl', '9998887777', 'Psychologia reklamy',6),
    (3, 'dr hab', 'Marek Nowakowski', 'marek.nowakowski@gmail.com', '1112223334', 'Podstawy hurtowni danych',7),
    (2, 'dr inz', 'Beata Jab³oñska', 'beata.jablonska@gmail.com', '5554443332', 'Komunikacja cz³owiek-komputer',8),
    (1, 'inz', 'Krzysztof Szymañski', 'krzysztof.szymanski@gmail.com', '2223334444', 'Big Data',9),
    (2, 'mgr', 'Ewa Adamczyk', 'ewa.adamczyk@wp.pl', '7776665555', 'Programowanie gier komputerowych',10),
    (3, 'dr hab', 'Rafa³ Lewandowski', 'rafal.lewandowski@gmail.com', '3335557777', 'Historia grafiki',11),
    (1, 'dr inz', 'Dorota Pawlak', 'dorota.pawlak@gmail.com', '8889990000', 'Programowanie obiektowe',12),
    (2, 'inz', 'Marcin Kowal', 'marcin.kowal@wp.pl', '1112223335', 'Uczenie maszynowe',13),
    (3, 'mgr', 'Agnieszka Zieliñska', 'agnieszka.zielinska@wp.pl', '4445556666', 'Sztuczna inteligencja',14),
    (1, 'dr hab', 'Grzegorz Witkowski', 'grzegorz.witkowski@gmail.com', '9990001111', 'Cyberbezpieczeñstwo',15);

-- Egzaminy

INSERT INTO Egzaminy (semestr, dydaktyk, system_egz, tryb, kierunek, id_ucznia, id_dyd )
VALUES
    (1, 'Anna Nowak', 'Licencjackie', 'zaoczny', 'Informatyka',1,1),
    (2, 'Jan Kowalski', 'Magisterskie', 'dzienny', 'Sztuczna inteligencja',2,2),
    (1, 'Maria Lis', 'Inzynierskie', 'eksternistyczny', 'Bazy danych',3,3),
    (3, 'Piotr Zaj¹c', 'Licencjackie', 'dzienny', 'Informatyka',4,4),
    (2, 'Tomasz Wójcik', 'Magisterskie', 'zaoczny', 'Informatyka',5,5),
    (1, 'Alicja Kowalczyk', 'Inzynierskie', 'dzienny', 'Grafika',6,6),
    (3, 'Marek Nowakowski', 'Licencjackie', 'eksternistyczny', 'Bazy danych',7,7),
    (2, 'Beata Jab³oñska', 'Magisterskie', 'zaoczny', 'Sztuczna inteligencja',8,8),
    (1, 'Krzysztof Szymañski', 'Inzynierskie', 'dzienny', 'Sztuczna inteligencja',9,9),
    (2, 'Ewa Adamczyk', 'Licencjackie', 'eksternistyczny', 'Informatyka',10,10),
    (3, 'Rafa³ Lewandowski', 'Magisterskie', 'dzienny', 'Grafika',11,11),
    (1, 'Dorota Pawlak', 'Inzynierskie', 'zaoczny', 'Informatyka',12,12),
    (2, 'Marcin Kowal', 'Licencjackie', 'dzienny', 'Sztuczna inteligencja',13,13),
    (3, 'Agnieszka Zieliñska', 'Magisterskie', 'eksternistyczny', 'Sztuczna inteligencja',14,14),
    (1, 'Grzegorz Witkowski', 'Inzynierskie', 'zaoczny', 'Cyberbezpieczeñstwo',15,15); 



--Oceny
INSERT INTO Oceny (przedmiot, forma, ocena_koncowa, zaliczony,id_ucznia)
VALUES
    ('Technologie webowe', 'Wyklad', 4.5, 1, 1),
	('Strategia biznesowa i AI', 'Wyklad', 5.0, 1,2),
	('Bazy danych','Laboratorium', 4.5, 1,3),
	('Technologie XML','Projekt', 3.0, 0, 4),
    ('Technologie XML', 'Laboratorium', 3.8, 0,5),
	('Programowanie obiektowe', 'Wyklad', 4.0, 1, 5),
	('Psychologia reklamy','Projekt', 4.5, 1, 6),
	('Podstawy hurtowni danych','Laboratorium',6.0,1,7),
	('Komunikacja cz³owiek-komputer','Wyklad', 3.0, 0,8),
	('Big Data','Laboratorium', 4.0, 1,9),
	( 'Programowanie gier komputerowych','Wyklad', 3.6, 0, 10),
	('Historia grafiki','Laboratorium',4.5, 1, 11),
	('Programowanie gier komputerowych', 'Laboratorium', 3.2, 0, 11),
	('Programowanie obiektowe','Wyklad', 4.6, 1,12),
	('Uczenie maszynowe','Laboratorium',3.7, 0, 13),
	('Sztuczna inteligencja','Projekt', 5.9, 1,14),
	('Cyberbezpieczeñstwo','Wyklad', 3.4, 0, 15),
    ('In¿ynieria oprogramowania', 'Projekt', 5.0, 1,15);


-- Moje_finanse
INSERT INTO Moje_finanse (stan_konta, konto_wplat, data_ostatniej_wplaty, kwota_wplaty, typ_transakcji, opis_transakcji, data_zaksiegowania, status_wplaty, id_ucznia)
VALUES
    (1000, 12345678901234567890123456, '2024-01-10', 500.00, 'przelew', 'Wplata za czesne', '2024-01-10 10:00:00', 'Op³acone',1),
    (1500, 98765432109876543210987654, '2024-01-11', 200.00, 'gotowka', 'Wplata za legitymacje studencka', '2024-01-11 12:30:00', 'Op³acone',2),
    (2000, 11112222333344445555666677, '2024-01-12', 1000.00, 'przelew', 'Wplata za czesne', '2024-01-12 15:45:00', 'Op³acone',3),
    (800, 99998888777766665555444433, '2024-01-13', 300.00, 'gotowka', 'Oplata za rekrutacje', '2024-01-13 08:00:00', 'Op³acone',4),
    (1200, 87654321098765432109876543, '2024-01-14', 150.00, 'przelew', 'Wplata za czesne', '2024-01-14 17:20:00', 'Op³acone',5),
    (300, 44443333222211110000111122, '2024-01-15', 400.00, 'gotowka', 'Oplata za rekrutacje', '2024-01-15 14:10:00', 'Op³acone',6),
    (2500, 55556666777788889999000011, '2024-01-16', 600.00, 'przelew', 'Wplata za egzamin', '2024-01-16 11:45:00', 'Op³acone',7),
    (1800, 12340000123456780000123456, '2024-01-17', 750.00, 'gotowka', 'Wplata za czesne', '2024-01-17 09:30:00', 'Op³acone',8),
    (600, 78901234567890123456789012, '2024-01-18', 200.00, 'przelew', 'Wplata za egzamin', '2024-01-18 13:15:00', 'Op³acone',9),
    (3500, 13579135791357913579135791, '2024-01-19', 1200.00, 'gotowka', 'Wplata za semestr', '2024-01-19 16:55:00', 'Op³acone',10),
    (900, 24680246802468024680246802, '2024-01-20', 450.00, 'przelew', 'Wplata za egzamin', '2024-01-20 20:05:00', 'Op³acone',11),
    (2700, 98765432100000000000000000, '2024-01-21', 800.00, 'gotowka', 'Oplata za rekrutacje', '2024-01-21 18:40:00', 'Op³acone',12),
    (700, 11111111111111111111111111, '2024-01-22', 100.00, 'przelew', 'Wplata za czesne', '2024-01-22 22:25:00', 'Op³acone',13),
    (1300, 22222222222222222222222222, '2024-01-23', 350.00, 'gotowka', 'Wplata za egzamin', '2024-01-23 14:50:00', 'Op³acone',14),
    (2400, 33333333333333333333333333, '2024-01-24', 600.00, 'przelew', 'Oplata za rekrutacje', '2024-01-24 11:15:00', 'Op³acone',15);

--Tok studiow
INSERT INTO Tok_studiow (data_rozp_st, data_zak_st, data_ts, opis_ts, id_ucznia)
VALUES
    ('2024-01-10', '2024-02-15', '2024-01-12', 'Rejestracja na semestr',1),
    ('2024-02-20', '2024-04-05', '2024-02-25', 'Rozliczenie semestru',2),
    ('2024-04-10', '2024-05-20', '2024-04-15', 'Przedluzenie sesji egzaminacyjnej',3),
    ('2024-06-01', '2024-07-15', '2024-06-05', 'Wybor specjalizacji',4),
    ('2024-07-20', '2024-08-30', '2024-07-25', 'Rekrutacja',5),
    ('2024-09-01', '2024-10-15', '2024-09-05', 'Rozpoczecie systemu IOS',6),
    ('2024-11-01', '2024-12-20', '2024-11-05', 'Zakonczenie systemu IOS',7),
    ('2025-01-10', '2025-02-25', '2025-01-15', 'Zmiana grupy',8),
    ('2025-03-01', '2025-04-15', '2025-03-05', 'Nadanie numeru indeksu',9),
    ('2025-04-20', '2025-06-05', '2025-04-25', 'Rejestracja na semestr',10),
    ('2025-06-10', '2025-07-25', '2025-06-15', 'Rozliczenie semestru',11),
    ('2025-08-01', '2025-09-15', '2025-08-05', 'Przedluzenie sesji egzaminacyjnej',12),
    ('2025-09-20', '2025-10-30', '2025-09-25', 'Wybor specjalizacji',13),
    ('2025-11-01', '2025-12-15', '2025-11-05', 'Rekrutacja',14),
    ('2026-01-10', '2026-02-25', '2026-01-15', 'Rozpoczecie systemu IOS',15);


SELECT * FROM Profil;
SELECT * FROM Plan_zajec;
SELECT * FROM Egzaminy;
SELECT * FROM Dydaktycy;
SELECT * FROM Oceny;
SELECT * FROM Moje_finanse;
SELECT * FROM Tok_studiow;


/*Zapytania 
Podgl¹d danych znajduj¹cych siê w bazie mo¿na uzyskaæ poprzez odpowiednie zapytania wybieraj¹ce –

nale¿y uwzglêdniæ minimum 10 zapytañ, w ramach zapytañ nale¿y uwzglêdniæ funkcje agreguj¹ce, podzapytania.

Wprowadzanie, usuwanie i aktualizowanie danych odbywa siê poprzez odpowiednie polecenia SQL. */


/* 1. Ktorzy uczniowie s¹ na systemie ios ( indywidualna organizacja studiow ) */

SELECT 
	id_ucznia, imie, nazwisko, ios 
FROM 
	Profil 
WHERE 
	ios='1';

/* 2. Jaki dokladnie egzamin przeprowadza dydaktyk Anna Nowak oraz jaki uczeñ podlega jej przy tym egzaminie. */

SELECT 
	Egzaminy.id_dyd, Egzaminy.dydaktyk, Egzaminy.kierunek ,Egzaminy.id_ucznia, Profil.imie, Profil.nazwisko, Profil.id_ucznia, Profil.nr_indeksu  
FROM 
	Egzaminy
JOIN 
	Profil ON Egzaminy.id_ucznia=Profil.id_ucznia
WHERE 
	Egzaminy.dydaktyk='Anna Nowak' 
	AND 
	Profil.id_ucznia='1';

/* 3. Ktory uczen jako pierwszy podpisal umowe z uczelnia */

SELECT TOP 1 
	data_podpisania_umowy AS pierwsza_podpisana_umowa,
	imie, nazwisko 
FROM 
	Profil 
ORDER BY 
	data_podpisania_umowy ASC;

/* 4. Podsumuj ile dokladnie uczelnia zarobila na studentach */

SELECT 
	SUM(stan_konta) AS przychod_uczelnii 
FROM 
	Moje_finanse;

/* 5. Dowiedz sie co Natalia ma wpisane w toku studiow i z jaka tabela jest to powiazane */

SELECT 
	Tok_studiow.id_ucznia, Tok_studiow.opis_ts, Profil.id_ucznia, Profil.imie, Profil.nazwisko, Profil.email, Profil.miejsce_urodzenia
FROM 
	Tok_studiow
INNER JOIN
	Profil ON Tok_studiow.id_ucznia=Profil.id_ucznia
WHERE
	Profil.imie='Natalia';

/* 6. Sprawdz ile uczniow zostalo przyjetych na uczelnie */

SELECT 
	COUNT(*) AS Liczba_uczniow_przyjetych_na_uczelnie
FROM
	Profil
WHERE
	data_rekrutacji IS NOT NULL;

/* 7. Jakie dokladnie sa zajecia na uczelni dnia 16 stycznia 2024 roku */

SELECT 
	* 
FROM 
	Plan_zajec 
WHERE 
	data_zjazdu='2024-01-16';

/* 8. Sprawdz jaki uczen ma jakie oceny  */

SELECT 
	Profil.imie AS imie_u,
	Profil.nazwisko AS nazwisko_u,
	Oceny.ocena_koncowa,
	Oceny.przedmiot
FROM 
	Oceny 
JOIN 
	Profil ON Profil.id_ucznia=Oceny.id_ucznia;

/* 9 Podaj maksymalny stan konta oraz zrób to za pomoc¹ podzapytania  */
SELECT 
    Profil.id_ucznia, 
    Profil.imie, 
    Profil.nazwisko, 
    (SELECT MAX(stan_konta) FROM Moje_finanse) AS maksymalny_stan_konta
FROM Profil;

/* 10. Jakiego przedmiotu uczy Krzysztof Szymañski, jaki tytul naukowy posiada oraz jaki uczen pod niego podlega */

SELECT 
	id_dyd,Profil.id_ucznia, Dydaktycy.id_ucznia ,tytul_nauk, dydaktyk 
FROM 
	Dydaktycy  
CROSS JOIN 
	Profil 
WHERE 
	dydaktyk='Krzysztof Szymañski';















