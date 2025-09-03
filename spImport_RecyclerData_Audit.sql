USE [BankMachineDataWarehouse]
GO
/****** Object:  StoredProcedure [dbo].[spImport_RecyclerData_Audit]    Script Date: 9/2/2025 6:26:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER Procedure [dbo].[spImport_RecyclerData_Audit]
							@ImportedDocumentId		UniqueIdentifier	= null,
							@Debug				Char(1)			= 'N',
							@CasinoInsightDatabaseName	VarChar(100)		= Null,
							@RetrieveCoreCodeOnly		BIT = 0

							
as
set nocount on
Declare @Sql nvarchar(max)

BEGIN

Set Nocount On

if IsNull(@Debug, 'N') = 'N'
	Update	RecyclerData_Raw
	Set	ImportedDocumentId = @ImportedDocumentId
	Where	ImportedDocumentId Is Null

Select	[Business Date]			
		,Employee				
		,Station				
		,[Type]			
		,Amount
		,CONVERT(date,NULL)				gd_Converted							
		,CONVERT(decimal(10,2),NULL)	amt_Converted
		,ImportedDocumentId
Into	#RawData
From	RecyclerData_Raw
Where	RecyclerData_Raw.ImportedDocumentId = @ImportedDocumentId



---------------------------------------------------------------------------
-- update convereted columns
---------------------------------------------------------------------------

UPDATE #RawData
SET gd_Converted				=			CONVERT(DATE, [Business Date])
UPDATE #RawData
SET amt_Converted				=			CONVERT(decimal(10,2), Amount)

-- update ImportedDocument Set RowsInserted = 0 Where SourceTableId = 144
if IsNull(@Debug, 'N') = 'N'
	select @Sql = N'Update	'+@CasinoInsightDatabaseName+'..ImportedDocument
	Set	RowsInserted = ( Select Count(1) From #RawData  )
	Where	ImportedDocument.Id = @ImportedDocumentId
	'
execute sp_executeSQL @sql, N'@ImportedDocumentId UniqueIdentifier', @ImportedDocumentId



If IsNull(@Debug, 'N') = 'N'
	Insert RecyclerData
	(			
		GameDay				
		,EmployeeId			
		,Station
		,[Type]
		,Amount
		,TransactionType
		,ImportedDocumentId
	)
	Select	
		 gd_Converted
		 ,Employee	
		 ,Station
		 ,[Type]
		 ,amt_Converted
		 ,ImportedDocumentId
	From	#RawData
	Where Not Exists ( Select 1 From RecyclerData (NoLock) Where RecyclerData.ImportedDocumentId = @ImportedDocumentId)
Else
	Select * From RecyclerData

--SET IDENTITY_INSERT CreditCardCashAdvanceCashClub OFF

End

--get rid of any temp table abominations that have been created
Drop Table #RawData
