use BookStore;
drop table if exists administrative_regions, administrative_units, provinces, districts, wards;

CREATE TABLE administrative_regions (
	id integer NOT NULL,
	name varchar(255) NOT NULL,
	name_en varchar(255) NOT NULL,
	code_name varchar(255) NULL,
	code_name_en varchar(255) NULL,
	CONSTRAINT administrative_regions_pkey PRIMARY KEY (id)
);


-- CREATE administrative_units TABLE
CREATE TABLE administrative_units (
	id integer NOT NULL,
	full_name varchar(255) NULL,
	full_name_en varchar(255) NULL,
	short_name varchar(255) NULL,
	short_name_en varchar(255) NULL,
	code_name varchar(255) NULL,
	code_name_en varchar(255) NULL,
	CONSTRAINT administrative_units_pkey PRIMARY KEY (id)
);


-- CREATE provinces TABLE
CREATE TABLE provinces (
	code varchar(20) NOT NULL,
	name varchar(255) NOT NULL,
	name_en varchar(255) NULL,
	full_name varchar(255) NOT NULL,
	full_name_en varchar(255) NULL,
	code_name varchar(255) NULL,
	administrative_unit_id integer NULL,
	administrative_region_id integer NULL,
	CONSTRAINT provinces_pkey PRIMARY KEY (code)
);


-- provinces foreign keys

ALTER TABLE provinces ADD CONSTRAINT provinces_administrative_region_id_fkey FOREIGN KEY (administrative_region_id) REFERENCES administrative_regions(id);
ALTER TABLE provinces ADD CONSTRAINT provinces_administrative_unit_id_fkey FOREIGN KEY (administrative_unit_id) REFERENCES administrative_units(id);

CREATE INDEX idx_provinces_region ON provinces(administrative_region_id);
CREATE INDEX idx_provinces_unit ON provinces(administrative_unit_id);


-- CREATE districts TABLE
CREATE TABLE districts (
	code varchar(20) NOT NULL,
	name varchar(255) NOT NULL,
	name_en varchar(255) NULL,
	full_name varchar(255) NULL,
	full_name_en varchar(255) NULL,
	code_name varchar(255) NULL,
	province_code varchar(20) NULL,
	administrative_unit_id integer NULL,
	CONSTRAINT districts_pkey PRIMARY KEY (code)
);


-- districts foreign keys

ALTER TABLE districts ADD CONSTRAINT districts_administrative_unit_id_fkey FOREIGN KEY (administrative_unit_id) REFERENCES administrative_units(id);
ALTER TABLE districts ADD CONSTRAINT districts_province_code_fkey FOREIGN KEY (province_code) REFERENCES provinces(code);

alter table districts add index idx_districts_province (province_code);
alter table districts add index idx_districts_unit (administrative_unit_id);

-- CREATE wards TABLE
CREATE TABLE wards (
	code varchar(20) NOT NULL,
	name varchar(255) NOT NULL,
	name_en varchar(255) NULL,
	full_name varchar(255) NULL,
	full_name_en varchar(255) NULL,
	code_name varchar(255) NULL,
	district_code varchar(20) NULL,
	administrative_unit_id integer NULL,
	CONSTRAINT wards_pkey PRIMARY KEY (code)
);


-- wards foreign keys

ALTER TABLE wards ADD CONSTRAINT wards_administrative_unit_id_fkey FOREIGN KEY (administrative_unit_id) REFERENCES administrative_units(id);
ALTER TABLE wards ADD CONSTRAINT wards_district_code_fkey FOREIGN KEY (district_code) REFERENCES districts(code);

-- CREATE INDEX idx_wards_district ON wards(district_code);
-- CREATE INDEX idx_wards_unit ON wards(administrative_unit_id);

alter table wards add index idx_wards_district (district_code);
alter table wards add index idx_wards_unit (administrative_unit_id);

create table if not exists Account(
    Id int auto_increment NOT null PRIMARY key,
    Email varchar(254) not null check (Email like '%_@_%._%'),
    Password VARCHAR(100) not null,
    IsVerify BIT not null DEFAULT 0,
    IsActive BIT not null DEFAULT 0,
    Role VARCHAR(20) Default 'Guest' CHECK (Role in ('Guest','Admin','Manager')),
    unique(Email)
);

-- create index email_idx on Account(Email) using btree;
alter table Account add index email_idx (Email) using btree;


create table if not exists UserInformation(
    Id int auto_increment NOT null PRIMARY key,
    AccountId int NOT NULL REFERENCES Account(Id) on delete CASCADE,
    AddressDefaultId int REFERENCES UserAddress(Id) on delete set null,
    FirstName VARCHAR(100) not null, 
    LastName VARCHAR(100) not null,
    PhoneNumber VARCHAR(20),
    Sex TINYINT not null check (Sex < 4 and Sex > 0),
    AvatarURL TEXT,
    unique(AccountId)
);

create table if not exists UserAddress(
	Id int auto_increment NOT null PRIMARY key,
    UserId int not null references UserInformation(Id) on delete cascade,
    Province VARCHAR (20) references provinces(code),
    District VARCHAR(20) references districts(code),
    Ward varchar(20) references wards(code),
    Street varchar(100)
);

create table if not exists Brand(
    Id int auto_increment NOT null PRIMARY key,
    BrandName Varchar(100) not null,
    LogoURL TEXT,
    CountryId int references Country(Id) on delete set null,
    fulltext (BrandName)
);

create table if not exists Country (
	Id int auto_increment not null primary key,
    CountryName Varchar(100),
    ISO char(2),
    unique(CountryName),
    unique(ISO)
);

create table if not exists Category (
	Id int auto_increment not null primary key,
    CategoryName Varchar(100) not null,
    CategoryDescription Text
);

create table if not exists Product (
	Id varchar(100) not null,
    ImageURL text not null,
    Price MEDIUMINT not null,
	ProductTitle Varchar(100) not null,
    ProductDescription Text,
    ProductContentURL Text,
    BrandId int,
    CategoryId int,
    QuantityAvailable int,
    QuantitySold int,
    constraint product_unique unique(Id, Price)
) 
Partition by range (Price) (
	Partition price_1 values less than (50000),
    partition price_2 values less than (100000),
    partition price_3 values less than (300000),
    partition price_4 values less than (MAXValue)
);
-- create index product_brand_idx on Product(BrandId) using hash;
-- create index product_category_idx on Product(CategoryId) using hash;

alter table Product add index product_brand_idx (BrandId) using hash;
alter table Product add index product_category_idx (CategoryId) using hash;

create table if not exists Feedback (
	Id int auto_increment not null primary key,
    UserId int not null references UserInformation(Id) on delete cascade,
    ProductId varchar(100) not null references Product(Id) on delete cascade,
    CommentContent text not null,
    Rate tinyint not null check (Rate>0 and Rate<6)
);

-- create index feedback_idx on Feedback(ProductId) using hash;
alter table Feedback add index feedback_idx (ProductId) using hash;

create table if not exists ProductImage(
	Id int auto_increment not null primary key,
	ProductId varchar(100) not null references Product(Id) on delete cascade,
    ImageURL text not null
);

-- create index product_img_idx on ProductImage(ProductId) using hash;
alter table ProductImage add index product_img_idx (ProductId) using hash;

create table if not exists OrderDetail(
	Id int auto_increment not null primary key,
	CreatedTime Datetime not null default Now(),
    UserId int not null references UserInformation(Id) on delete cascade,
    ProcessStatus varchar(10) not null default "created" check(ProcessStatus in ('created','pending','delivering','done')),
    PaymentStatus bit not null default 0,
    PaymentMethod varchar(10) not null default "cash" check(PaymentMethod in ('cash','visa card','master card','momo','bank')),
    Total MEDIUMINT not null,
    Province VARCHAR (20) references provinces(code),
    District VARCHAR(20) references districts(code),
    Ward varchar(20) references wards(code),
    Street varchar(100),
    PhoneNumber varchar(20) not null,
    SpecialOfferId int references SpecialOffer(Id)
);
-- create index order_detail_user_idx on OrderDetail(UserId) using hash;
alter table OrderDetail add index order_detail_user_idx (UserId) using hash;

create table if not exists OrderProductSale (
	Id int auto_increment not null primary key,
    ProductId varchar(100) not null references Product(Id),
    OrderDetailId int not null references OrderDetail(Id),
    OrderQty tinyint not null
);

create table if not exists SpecialOffer (
	Id int auto_increment not null primary key,
	Discount tinyint not null,
    SpecialOfferDiscription Text,
    SpecialOfferCondition tinyint
);

create table if not exists DeliveryCost (
	Id int auto_increment not null primary key,
    Cost tinyint not null,
    ProvinceId varchar(20) not null references provinces(code)
)
