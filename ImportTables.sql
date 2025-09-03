USE [BankMachineDataWarehouse]
GO

-- RAW Data Table for Viewing Activity
IF OBJECT_ID('dbo.RecyclerData_Raw') IS NULL
BEGIN
	CREATE TABLE dbo.RecyclerData_Raw
		(
		[Business Date]					varchar(1000)				Null,
		Employee						varchar(1000)				Null,
		Station							varchar(1000)				Null,
		[Type]							varchar(1000)				Null,
		Amount							varchar(1000)				Null,
		ImportedDocumentId				UniqueIdentifier			Null
		)
END

--Physical Data Table for Viewing Activity
IF OBJECT_ID('dbo.RecyclerData') IS NULL
BEGIN
	CREATE TABLE dbo.RecyclerData
		(
		Id								int identity(1,1)		Not Null,
		GameDay							date						Null,
		EmployeeId						varchar(10)					Null,
		Station							varchar(100)				Null,
		[Type]							varchar(100)				Null,
		Amount							decimal(10,2)				Null,
		IsVoid							bit						Not Null DEFAULT 0,
		ImportedDocumentId				UniqueIdentifier		Not Null
		)
END

SELECT * FROM RecyclerData_Raw
SELECT * FROM RecyclerData
