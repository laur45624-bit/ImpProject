USE [BankMachineDataWarehouse]
GO

ALTER PROCEDURE [dbo].[spRetrieve_RecyclerData_Audit]
				@FromDate Datetime = '11/10/2024',
				@ToDate Datetime   = '11/17/2024',
				@EmployeeJoinOverride	NVARCHAR(MAX) = NULL

AS
--Gathered from the [dbo].[spRevenueAudit_ManageData_CashierShift_Extension_Recycler]
IF OBJECT_ID('tempdb..#RecyclerData') IS NULL
CREATE TABLE #RecyclerData (
	-- Source System Dimensions
	[Source System Id]			INT			NULL,
	[Source System Name]			VARCHAR(100)		NULL,
	[Source System Site]			VARCHAR(100)		NULL,

	-- Machine Dimensions
	[Machine Id]				INT			NULL,
	[Machine Idnty]				INT			NULL,
	[Machine Name]				VARCHAR(100)		NULL,
	[Machine Location]			VARCHAR(100)		NULL,
	
	-- Transaction Dimensions
	[Id]					INT			NULL,
	[External Transaction Id]		INT			NULL,
	[IsOverridden]				BIT			NULL,
	[IsActive]				BIT			NULL,
	[Original IsActive]			BIT			NULL,
	[Game Day]				DATE			NULL,
	[Original Game Day]			DATE			NULL,
	[Transaction Date/Time]			DATETIME		NULL,
	
	-- RecyclerData Dimensions
	[Transaction Type]			VARCHAR(50)		NULL,
	[Description]				VARCHAR(100)		NULL,
	
	-- Transaction Measures
	[Transaction Count]			INT			NULL,
	[Amount]				MONEY			NULL,
	[RecyclerOtherAmount1]			MONEY			NULL,
	[RecyclerOtherAmount2]			MONEY			NULL,
	[RecyclerOtherAmount3]			MONEY			NULL,
	[RecyclerOtherAmount4]			MONEY			NULL,
	[RecyclerOtherAmount5]			MONEY			NULL,
	[Employee]				VARCHAR(100)		NULL,
	[Bank Type]				VARCHAR(100)		NULL,
	[Category]				VARCHAR(100)		NULL,

	-- Additional Columns
	[EmployeeId]				UNIQUEIDENTIFIER	NULL,
	[Original EmployeeId]			UNIQUEIDENTIFIER	NULL,
	[Recycler User Description]		VARCHAR(125)		NULL,
	[Original Recycler User Description]	VARCHAR(125)		NULL,
	[CashierShiftId]			UNIQUEIDENTIFIER	NULL,
	[AdditionalParameters]			VARCHAR(255)		NULL,

	--Attribute Columns
	[Original Employee]			VARCHAR(100)		NULL,
	[Original Bank Type]			VARCHAR(100)		NULL,
	[Original Category]			VARCHAR(100)		NULL,
	[Type]					VARCHAR(100)		NULL,
	[Original Type]				VARCHAR(100)		NULL,
	[Dispense Error]			VARCHAR(100)		NULL,
	[Revenue Center]			VARCHAR(100)		NULL,
	[Station]				VARCHAR(100)		NULL,
	[Tip Pool]				VARCHAR(100)		NULL,
	[Tip Pool Id]				UNIQUEIDENTIFIER	NULL,
	[Department]				VARCHAR(100)		NULL,
	[Department Id]				UNIQUEIDENTIFIER	NULL,
	[Type Description]			VARCHAR(255)		NULL,
	[IsSplit]				BIT			NULL,
	[IsDuplicate]				BIT			NULL,
	[Duplicate Id]				INT			NULL,
	[Note]					VARCHAR(255)		NULL,
	[AttributesSourceIntId]			INT			NULL,
	[AttributeRevisionDescription]		VARCHAR(4000)		NULL
	)


INSERT INTO #RecyclerData (
		[Id],
		[Game Day],
		[Employee],
		[Station],
		[Type],
		[Amount],
		[Transaction Type]
		)
SELECT 	Id
		,GameDay				
		,EmployeeId			
		,Station				
		,[Type]		
		,CASE
			WHEN [Type] LIKE '%Withdrawal%' THEN -(Amount)
			WHEN [Type] LIKE '%Deposit%' THEN (Amount)
			ELSE Amount
		END
		,'Recycler'
FROM RecyclerData
WHERE GameDay BETWEEN @FromDate AND @ToDate
	AND IsVoid <> 0;

IF OBJECT_ID('tempdb..#EmployeeMapping') IS NULL
CREATE TABLE #EmployeeMapping (
	EmployeeId	UNIQUEIDENTIFIER	NOT NULL,
	Employee	VARCHAR(1000)		NOT NULL
	)

EXECUTE [spAttribute_Manage_RecyclerData] @EmployeeJoinOverride = @EmployeeJoinOverride, @MappingOnly = 0

SELECT * FROM #RecyclerData
