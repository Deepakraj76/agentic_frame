/*  Titan database script
Functional Area:  Profile Forms
Tables included:
----------------------------------
Tables				Records    Most Recent					Action

FormCC	            415,241		7/2/2024                    Modify
FormCCDetail	    925,739		7/2/2024                    Modify
FormXApproval	  1,125,306		No date columns             Modify
FormGN	            122,414		6/18/2024                   Modify
FormGWA	             38,008		6/10/2024                   Modify
FormLDRSubcategory	325,563		No date columns             Modify
FormLDR	            243,733		7/1/2024                    Modify
FormLDRDetail	    395,485		No date columns             Modify
FormPQ	              1,754		6/4/2020                    Modify
FormRA	            104,464		6/10/2024                   Modify
FormSREC	          3,719		6/21/2024                   Modify
FormWCR_LDR	             28		No date columns             Ignore
FormWWA	                 58		11/13/2012                  Ignore
*/

---------------------------------------------------------------------------------------------
--89812- WS1 - Analysis - Profile Forms (13)

CREATE TABLE [dbo].[_FormCC](
	[formcc_uid] INTEGER IDENTITY(1,1) NOT NULL,				-- created new column as primary key
	[form_id] INTEGER NOT NULL,									-- composite unique constraint					
	[revision_id] INTEGER NOT NULL,								-- composite unique constraint						
	[form_version_id] INTEGER NULL,						
	[customer_id] INTEGER NULL,									-- FK to Customer.customer_id
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[approval_code] VARCHAR(15) NULL,
	[approval_key] INTEGER NULL,                      
	[company_id] INTEGER NULL,						
	[profit_ctr_id] INTEGER NULL,						
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormCC_created_by] DEFAULT SYSTEM_USER,     	-- Not NULL, varchar(60) -> varchar(100)
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormCC_date_created] DEFAULT GETDATE(),	  		-- Not NULL, Default added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormCC_modified_by] DEFAULT SYSTEM_USER,		-- Not NULL, varchar(60) -> varchar(100), Default added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormCC_date_modified] DEFAULT GETDATE(),    	-- Not NULL, Default added
	[customer_cust_name] VARCHAR(75) NULL,
	[customer_cust_addr1] VARCHAR(40) NULL,
	[customer_cust_addr2] VARCHAR(40) NULL,
	[customer_cust_addr3] VARCHAR(40) NULL,
	[customer_cust_addr4] VARCHAR(40) NULL,
	[customer_cust_addr5] VARCHAR(40) NULL,
	[customer_cust_city] VARCHAR(40) NULL,
	[customer_cust_state] VARCHAR(2) NULL,
	[customer_cust_zip_code] VARCHAR(15) NULL,
	[customer_cust_fax] VARCHAR(10) NULL,
	[contact_id] INTEGER NULL,									-- FK to Contact.contact_id
	[contact_name] VARCHAR(40) NULL,
	[company_company_name] VARCHAR(35) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	[profitcenter_scheduling_phone] VARCHAR(14) NULL,
	[company_ins_surcharge_percent] MONEY NULL,
	[approval_ap_expiration_date] DATETIME NULL,
	[generator_generator_name] VARCHAR(75) NULL,
	[approval_approval_desc] VARCHAR(50) NULL,
	[wastecode_waste_code_desc] VARCHAR(60) NULL,
	[wastecode_waste_code] VARCHAR(4) NULL,
	[secondary_waste_code_list] VARCHAR(3600) NULL,				-- TEXT to VARCHAR(3600)
	[approval_ots_flag] CHAR(1) NULL,
	[generator_epa_id] VARCHAR(12) NULL,
	[generator_id] INTEGER NULL,								-- FK to Generator.generator_id
	[QuoteDetailDesc_description] VARCHAR(2000) NULL,			-- TEXT to VARCHAR(2000)
	[purchase_order] VARCHAR(20) NULL,
	[release] VARCHAR(20) NULL,
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,		-- remove rowguid column
	[profile_id] INTEGER NULL,									-- FK to Profile.profile_id
	[ensr_applied_flag] CHAR(1) NULL,
	CONSTRAINT [PK_FormCC] PRIMARY KEY CLUSTERED ([formcc_uid])
)
GO

--new unique constraints
ALTER TABLE dbo._FormCC WITH CHECK ADD CONSTRAINT UK_FormCC UNIQUE (form_id, revision_id);

--new foreign keys
ALTER TABLE [dbo].[_FormCC] ADD  CONSTRAINT [FK_FormCC_customer] FOREIGN KEY([customer_id]) REFERENCES [dbo].[_customer] ([customer_id]);
ALTER TABLE [dbo].[_FormCC] ADD  CONSTRAINT [FK_FormCC_contact] FOREIGN KEY([contact_id]) REFERENCES [dbo].[_contact] ([contact_id]);
ALTER TABLE [dbo].[_FormCC] ADD  CONSTRAINT [FK_FormCC_generator] FOREIGN KEY([generator_id]) REFERENCES [dbo].[_generator] ([generator_id]);
ALTER TABLE [dbo].[_FormCC] ADD  CONSTRAINT [FK_FormCC_profile] FOREIGN KEY([profile_id]) REFERENCES [dbo].[_profile] ([profile_id]);

/*Justification for FK

select pq.customer_id
  from FormCC pq
  left join customer p on pq.customer_id = p.customer_id
 where p.customer_id IS NULL
 and pq.customer_id IS NOT NULL
--0 rows

select pq.contact_id
  from FormCC pq
 left join contact p on pq.contact_id = p.contact_id
where p.contact_id IS NULL
  and pq.contact_id IS NOT NULL
--53233 rows

select pq.contact_id, COUNT(pq.contact_id) as CT
  from FormCC pq
 left join contact p on pq.contact_id = p.contact_id
where p.contact_id IS NULL
  and pq.contact_id IS NOT NULL
 group by pq.contact_id

contact_id	CT
0	53167
1334	22
3636	1
233122	3
213386	5
213665	4
5545	9
6340	1
5907	19
10919	2

select pq.generator_id
  from FormCC pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id is NULL
   and pq.generator_id IS NOT NULL
--1 row  [generator_id = 71659]

select pq.profile_id
  from FormCC pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id is NULL
   and pq.profile_id IS NOT NULL
--0 rows
*/

/*Justification for not null values 
select * from FormCC where date_created is null or date_created = '' 
--0 rows

select * from FormCC where date_modified is null or date_modified = '' 
--0 rows

select * from FormCC where Modified_by is null or Modified_by = '' 
--13 rows

select * from FormCC where created_by is null or created_by = '' 
--13 rows
*/

/*
--Justification for column length adjustments
select TOP 5 DATALENGTH([secondary_waste_code_list])
  from FormCC
 order by DATALENGTH([secondary_waste_code_list]) DESC
--3346, 2620, 2524, 2518, 2512

select TOP 5 DATALENGTH([QuoteDetailDesc_description])
  from FormCC
 order by DATALENGTH([QuoteDetailDesc_description]) DESC
--2000, 2000, 1460, 1347, 1347
*/

--------------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormCCDetail](
	[FormCCDetail_uid] INTEGER IDENTITY(1,1) NOT NULL,			-- created new column as primary key
	[form_id] INTEGER NULL,										-- Composite FK to FormCC.form_id
	[revision_id] INTEGER NULL,									-- Composite FK to FormCC.revision_id
	[form_version_id] INTEGER NULL,					
	[approval_key] INTEGER NULL,
	[quotedetail_sequence_id] INTEGER NULL,
	[quotedetail_record_type] CHAR(1) NULL,
	[quotedetail_service_desc] VARCHAR(60) NULL,
	[approval_sr_type_code] CHAR(1) NULL,
	[profitcenter_surcharge_flag] CHAR(1) NULL,
	[quotedetail_surcharge_price] FLOAT NULL,
	[quotedetail_hours_free_unload] INTEGER NULL,
	[quotedetail_hours_free_loading] INTEGER NULL,
	[quotedetail_demurrage_price] FLOAT NULL,
	[quotedetail_unused_truck_price] FLOAT NULL,
	[quotedetail_lay_over_charge] FLOAT NULL,
	[quotedetail_bill_method] CHAR(1) NULL,
	[quotedetail_price] FLOAT NULL,
	[quotedetail_bill_unit_code] VARCHAR(4) NULL,				-- FK to BillUnit.bill_unit_code
	[quotedetail_min_quantity] FLOAT NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormCCDetail_created_by] DEFAULT SYSTEM_USER,     	-- Not NULL, varchar(60) -> varchar(100) modified
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormCCDetail_date_created] DEFAULT GETDATE(),	  		-- Not NULL, Default value added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormCCDetail_modified_by] DEFAULT SYSTEM_USER,		-- Not NULL, varchar(60) -> varchar(100), Default value added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormCCDetail_date_modified] DEFAULT GETDATE(),    		-- Not NULL, Default value added
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,		-- remove rowguid
	[company_id] INTEGER NULL,									-- Composite FK to Profitcenter.company_id
	[profit_ctr_id] INTEGER NULL,								-- Composite FK to Profitcenter.profit_ctr_id
	[ref_sequence_id] INTEGER NULL,
	CONSTRAINT [PK_FormCCDetail] PRIMARY KEY CLUSTERED ([FormCCDetail_uid])
)
GO

--changed clustered to non clustered
CREATE NONCLUSTERED INDEX IX_FormCCDetail ON dbo.FormCCDetail (form_id ASC, revision_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormCCDetail] ADD CONSTRAINT FK_FormCCDetail_formcc FOREIGN KEY (form_id, revision_id) REFERENCES [dbo].FormCC (form_id, revision_id);
ALTER TABLE [dbo].[_FormCCDetail] ADD CONSTRAINT FK_FormCCDetail_billunit FOREIGN KEY([quotedetail_bill_unit_code]) REFERENCES [dbo].[BillUnit] ([bill_unit_code]);
ALTER TABLE [dbo].[_FormCCDetail] ADD CONSTRAINT FK_FormCCDetail_profitcenter FOREIGN KEY (company_id,profit_ctr_id) REFERENCES [dbo].[Profitcenter] (company_id, profit_ctr_id);

/*Justification for FK
select pq.form_id, pq.revision_id
  from FormCCDetail pq
  left join formcc p on pq.form_id = p.form_id and pq.revision_id = p. revision_id
 where (p.form_id is NULL or p.revision_id is Null)
   and pq.form_id IS NOT NULL and pq.revision_id IS NOT NULL
--42 rows

select pq.quotedetail_bill_unit_code
  from FormCCDetail pq
  left join billunit p on pq.quotedetail_bill_unit_code = p.bill_unit_code
 where p.bill_unit_code IS NULL
   and pq.quotedetail_bill_unit_code IS NOT NULL
--0 rows

select pq.profit_ctr_id, pq.company_id
  from FormCCDetail pq
  left join profitcenter p on pq.company_id = p.company_id and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id is NULL or p.profit_ctr_id is Null)
   and pq.profit_ctr_id IS NOT NULL AND pq.company_id IS NOT NULL
--76 rows [profit_ctr_id = 2, company_id = 22]
*/


/*
--Justification for not null values 

select * from FormCCDetail where date_created is null or date_created = '' 
--0 rows 

select * from FormCCDetail where date_modified is null or date_modified = '' 
--0 rows

select * from FormCCDetail where Modified_by is null or Modified_by = '' 
--3 rows

select * from FormCCDetail where created_by is null or created_by = '' 
--32 rows
*/

-----------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormXApproval](
	[FormXApproval_uid] INTEGER IDENTITY(1,1) NOT NULL,			-- created new column as primary key
	[form_type] CHAR(10) NULL,
	[form_id] INTEGER NULL,										-- composite FK to FormCC.form_id
	[revision_id] INTEGER NULL,									-- composite FK to FormCC.revision_id
	[company_id] INTEGER NULL,									-- composite FK to ProfitCenter.company_id
	[profit_ctr_id] INTEGER NULL,								-- composite FK to ProfitCenter.profit_ctr_id
	[profile_id] INTEGER NULL,									-- FK to Profile.profile_id
	[approval_code] VARCHAR(15) NULL,
	[profit_ctr_name] VARCHAR(50) NULL,
	[profit_ctr_EPA_ID] VARCHAR(12) NULL,
	[insurance_surcharge_percent] MONEY NULL,
	[ensr_exempt] CHAR(1) NULL,
	[quotedetail_comment] VARCHAR(6400) NULL,					-- varchar(max) to varchar(6400)
	[added_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormXApproval_added_by] DEFAULT SYSTEM_USER,		-- new column
	[date_added] DATETIME NOT NULL CONSTRAINT [DF_FormXApproval_date_added] DEFAULT GETDATE(),			-- new column
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormXApproval_modified_by] DEFAULT SYSTEM_USER,	-- new column
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormXApproval_date_modified] DEFAULT GETDATE(),	-- new column
	CONSTRAINT [PK_FormXApproval] PRIMARY KEY CLUSTERED ([FormXApproval_uid])
)
GO

CREATE NONCLUSTERED INDEX IX_FormXApproval ON dbo.FormXApproval (form_id ASC, revision_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormXApproval] ADD CONSTRAINT FK_FormXApproval_formcc FOREIGN KEY (form_id, revision_id) REFERENCES dbo.FormCC (form_id, revision_id);
ALTER TABLE [dbo].[_FormXApproval] ADD CONSTRAINT FK_FormXApproval_profitcenter FOREIGN KEY (company_id,profit_ctr_id) REFERENCES [dbo].ProfitCenter (company_id, profit_ctr_id);
ALTER TABLE [dbo].[_FormXApproval] ADD CONSTRAINT [FK_FormXApproval_profile] FOREIGN KEY([profile_id]) REFERENCES [dbo].[Profile] ([profile_id]);

/*Justification for FK
select pq.form_id, pq.revision_id
  from FormXApproval pq
  left join formcc p on pq.form_id = p.form_id and pq.revision_id = p. revision_id
 where (p.form_id IS NULL or p.revision_id IS Null)
   and pq.form_id IS NOT NULL and pq.revision_id IS NOT NULL
--704,067 rows - implement deferred

select pq.profit_ctr_id, pq.company_id
  from FormXApproval pq
  left join profitcenter p on pq.company_id = p.company_id and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id IS NULL or p.profit_ctr_id IS NULL)
   and pq.profit_ctr_id IS NOT NULL AND pq.company_id IS NOT NULL
--0 rows

select pq.profile_id
  from FormXApproval pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id IS NULL
   and pq.profile_id IS NOT NULL
--0 rows
*/

-----------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormGN](
	[FormGN_uid] INTEGER IDENTITY(1,1) NOT NULL,				-- created new column as primary key
	[form_id] INTEGER NOT NULL,					    
	[revision_id] INTEGER NOT NULL,					
	[form_version_id] INTEGER NULL,					
	[customer_id] INTEGER NULL,									-- FK to Customer.customer_id
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[approval_code] VARCHAR(15) NULL,
	[approval_key] INTEGER NULL,
	[company_id] INTEGER NULL,					
	[profit_ctr_id] INTEGER NULL,					
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormGN_created_by] DEFAULT SYSTEM_USER,     	-- Not NULL, varchar(60) -> varchar(100) modified
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormGN_date_created] DEFAULT GETDATE(),	  		-- Not NULL, Default value added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormGN_modified_by] DEFAULT SYSTEM_USER,		-- Not NULL, varchar(60) -> varchar(100), Default value added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormGN_date_modified] DEFAULT GETDATE(),    	-- Not NULL, Default value added
	[customer_cust_name] VARCHAR(75) NULL,
	[customer_cust_fax] VARCHAR(20) NULL,
	[generator_id] INTEGER NULL,								-- FK to Generator.generator_id
	[generator_epa_id] VARCHAR(12) NULL,
	[generator_gen_mail_name] VARCHAR(75) NULL,
	[generator_gen_mail_address_1] VARCHAR(40) NULL,
	[generator_gen_mail_address_2] VARCHAR(40) NULL,
	[generator_gen_mail_address_3] VARCHAR(40) NULL,
	[generator_gen_mail_address_4] VARCHAR(40) NULL,
	[generator_gen_mail_address_5] VARCHAR(40) NULL,
	[generator_gen_mail_city] VARCHAR(40) NULL,
	[generator_gen_mail_state] VARCHAR(2) NULL,
	[generator_gen_mail_zip_code] VARCHAR(15) NULL,
	[generator_generator_contact] VARCHAR(40) NULL,
	[approval_waste_code] VARCHAR(4) NULL,
	[approval_approval_desc] VARCHAR(50) NULL,
	[approval_comments_1] VARCHAR(6400) NULL,					-- TEXT to VARCHAR(6400)
	[approval_ap_expiration_date] DATETIME NULL,
	[approval_ots_flag] CHAR(1) NULL,
	[wastecode_waste_code_desc] VARCHAR(60) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	[secondary_waste_code]VARCHAR(10) NULL,						-- TEXT to VARCHAR(10)
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,		-- remove rowguid
	[profile_id] INTEGER NULL,									-- FK to Profile.profile_id
	[generator_name] VARCHAR(75) NULL,
	CONSTRAINT [PK_FormGN] PRIMARY KEY CLUSTERED ([FormGN_uid])
)
GO

--changed the index name from FormGN_cui to ix_FormGN
CREATE UNIQUE NONCLUSTERED INDEX IX_FormGN ON dbo.FormGN (form_id ASC, profile_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormGN] ADD  CONSTRAINT [FK_FormGN_customer] FOREIGN KEY([customer_id]) REFERENCES [dbo].Customer ([customer_id]);
ALTER TABLE [dbo].[_FormGN] ADD  CONSTRAINT [FK_FormGN_generator] FOREIGN KEY([generator_id]) REFERENCES [dbo].Generator ([generator_id]);
ALTER TABLE [dbo].[_FormGN] ADD  CONSTRAINT [FK_FormGN_profile] FOREIGN KEY([profile_id]) REFERENCES [dbo].[Profile] ([profile_id]);

/*Justification for FK
select pq.customer_id
  from FormGN pq
  left join customer p on pq.customer_id = p.customer_id
 where p.customer_id IS NULL
   and pq.customer_id IS NOT NULL
--0 rows

select pq.generator_id
  from FormGN pq
  left join generator p on pq.generator_id = p.generator_id
where p.generator_id IS NULL
  and pq.generator_id IS NOT NULL
--0 rows

select pq.profile_id
  from FormGN pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id IS NULL
   and pq.profile_id IS NOT NULL
--0 rows
*/

/*
--Justification for not null values 

select * from FormGN where date_created is null or date_created = '' 
--0 rows

select * from FormGN where date_modified is null or date_modified = '' 
--0 rows

select * from FormGN where Modified_by is null or Modified_by = '' 
--0 rows

select * from FormGN where created_by is null or created_by = '' 
--0 rows
*/

/*
--Justification for column length adjustments
select TOP 10 DATALENGTH(approval_comments_1)
  from FormGN
 order by DATALENGTH(approval_comments_1) DESC
--16948, 16948, 16948, 16948, 16948, 16948, 6243
--Long values all have white space at end.  Trim will eliminate

select TOP 1 DATALENGTH(secondary_waste_code)
  from FormGN
 order by DATALENGTH(secondary_waste_code) DESC
--4
*/

--------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormGWA](
	[FormGWA_uid] INTEGER IDENTITY(1,1) NOT NULL,				-- created new column as primary key
	[form_id] INTEGER NOT NULL,					
	[revision_id] INTEGER NOT NULL,				
	[form_version_id] INTEGER NULL,				
	[customer_id_from_form] INTEGER NULL,
	[customer_id] INTEGER NULL,									-- FK to Customer.customer_id
	[app_id] VARCHAR(20) NULL,
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[approval_code] VARCHAR(15) NULL,
	[approval_key] INTEGER NULL,
	[company_id] INTEGER NULL,									-- Composite FK to ProfitCenter.company_id
	[profit_ctr_id] INTEGER NULL,								-- Composite FK to ProfitCenter.profit_ctr_id
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormGWA_created_by] DEFAULT SYSTEM_USER,     	-- Not NULL, varchar(60) -> varchar(100)
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormGWA_date_created] DEFAULT GETDATE(),		-- Not NULL, Default added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormGWA_modified_by] DEFAULT SYSTEM_USER,	-- Not NULL, varchar(60) -> varchar(100), Default added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormGWA_date_modified] DEFAULT GETDATE(),    	-- Not NULL, Default added
	[generator_name] VARCHAR(75) NULL,
	[EPA_ID] VARCHAR(12) NULL,
	[generator_id] INTEGER NULL,								-- FK to Generator.generator_id
	[generator_address1] VARCHAR(40) NULL,
	[cust_name] VARCHAR(75) NULL,
	[cust_addr1] VARCHAR(40) NULL,
	[inv_contact_name] VARCHAR(40) NULL,
	[inv_contact_phone] VARCHAR(20) NULL,
	[inv_contact_fax] VARCHAR(10) NULL,
	[tech_contact_name] VARCHAR(40) NULL,
	[tech_contact_phone] VARCHAR(20) NULL,
	[tech_contact_fax] VARCHAR(10) NULL,
	[waste_common_name] VARCHAR(50) NULL,
	[waste_code_comment] VARCHAR(100) NULL,						-- text to varchar(100) since largest length is 60
	[amendment] varchar(MAX) NULL,								-- largest length is 10023, need furthur investigation for data type change
	[gen_mail_addr1] VARCHAR(40) NULL,
	[gen_mail_addr2] VARCHAR(40) NULL,
	[gen_mail_addr3] VARCHAR(40) NULL,
	[gen_mail_addr4] VARCHAR(40) NULL,
	[gen_mail_addr5] VARCHAR(40) NULL,
	[gen_mail_city] VARCHAR(40) NULL,
	[gen_mail_state] VARCHAR(2) NULL,
	[gen_mail_zip_code] VARCHAR(15) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	[waste_code] VARCHAR(4) NULL,
	[secondary_waste_code_list] varchar(5000) NULL,				-- text to varchar(5000) since largest length is 4374		
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,		-- remove rowguid column
	[profile_id] INTEGER NULL,									-- FK to Profile.profile_id
	[ap_expiration_date] DATETIME NULL,
	[cust_fax] VARCHAR(20) NULL,
	[reapproval_profile_change] VARCHAR(4) NULL,
	[contact_id] INTEGER NULL,					
	[contact_name] VARCHAR(40) NULL,
	[cust_addr2] VARCHAR(40) NULL,
	[cust_addr3] VARCHAR(40) NULL,
	[cust_addr4] VARCHAR(40) NULL,
	[cust_city] VARCHAR(40) NULL,
	[cust_state] VARCHAR(2) NULL,
	[cust_zip_code] VARCHAR(15) NULL,
	[TAB] FLOAT NULL,
	CONSTRAINT [PK_FormGWA] PRIMARY KEY CLUSTERED ([FormGWA_uid])
)

--changed the index name from FormGWA_cui to ix_FormGWA
CREATE UNIQUE NONCLUSTERED INDEX IX_FormGWA ON dbo.FormGWA (form_id ASC, revision_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormGWA] ADD CONSTRAINT FK_FormGWA_customer FOREIGN KEY([customer_id]) REFERENCES [dbo].[_customer] ([customer_id]);
ALTER TABLE [dbo].[_FormGWA] ADD CONSTRAINT FK_FormGWA_profitcenter FOREIGN KEY (company_id,profit_ctr_id) REFERENCES [dbo].[ProfitCenter] (company_id, profit_ctr_id);
ALTER TABLE [dbo].[_FormGWA] ADD CONSTRAINT FK_FormGWA_generator FOREIGN KEY([generator_id]) REFERENCES [dbo].[_generator] ([generator_id]);
ALTER TABLE [dbo].[_FormGWA] ADD CONSTRAINT FK_FormGWA_profile FOREIGN KEY([profile_id]) REFERENCES [dbo].[_profile] ([profile_id]);

/*
--Justification for FK
select pq.customer_id
  from FormGN pq
  left join customer p on pq.customer_id = p.customer_id
 where p.customer_id IS NULL
   and pq.customer_id IS NOT NULL
--0 rows

select pq.profit_ctr_id, pq.company_id
  from FormGWA pq
  left join profitcenter p on pq.company_id = p.company_id
            and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id is NULL or p.profit_ctr_id is Null)
   and pq.profit_ctr_id IS NOT NULL and pq.company_id IS NOT NULL
--0 rows

select pq.generator_id
  from FormGWA pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id IS NULL
   and pq.generator_id IS NOT NULL
--0 rows

select pq.profile_id
  from FormGWA pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id IS NULL
   and pq.profile_id IS NOT NULL
--0 rows
*/

/*
--Justification for not null values 

select * from FormGWA where date_created is null or date_created = '' 
--0 rows

select * from FormGWA where date_modified is null or date_modified = '' 
--0 rows

select * from FormGWA where Modified_by is null or Modified_by = '' 
--17 rows

select * from FormGWA where created_by is null or created_by = '' 
--17 rows
*/


/*
select TOP 10 DATALENGTH(waste_code_comment)
  from FormGWA
 order by DATALENGTH(waste_code_comment) DESC
--60

select TOP 10 DATALENGTH(amendment)
  from FormGWA
 order by DATALENGTH(amendment) DESC
--10023, 4032, anomalous comment is garbage.
*/

-----------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormLDRSubcategory](
    [FormLDRSubcategory_uid] INTEGER IDENTITY(1,1) NOT NULL,		-- created new column as primary key
	[form_id] INTEGER NULL,											-- Composite FK to FormLDR.form_id
	[revision_id] INTEGER NULL,										-- Composite FK to FormLDR.revision_id
	[page_number] INTEGER NULL,
	[manifest_line_item] INTEGER NULL,
	[ldr_subcategory_id] INTEGER NULL,								-- FK to LDRSubcategory.subcategory_id
    [added_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormLDRSubcategory_added_by] DEFAULT SYSTEM_USER,			-- new column
    [date_added] DATETIME NOT NULL CONSTRAINT [DF_FormLDRSubcategory_date_added] DEFAULT GETDATE(),				-- new column                    
    [modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormLDRSubcategory_modified_by] DEFAULT SYSTEM_USER,		-- new column
    [date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormLDRSubcategorydate_modified] DEFAULT GETDATE(),		-- new column  
    CONSTRAINT [PK_FormLDRSubcategory] PRIMARY KEY CLUSTERED ([FormLDRSubcategory_uid])
)
GO


--new foreign keys
ALTER TABLE [dbo].[_FormLDRSubcategory] ADD CONSTRAINT FK_FormLDRSubcategory_formLDR FOREIGN KEY (form_id, revision_id) REFERENCES [dbo].FormLDR (form_id, revision_id);
ALTER TABLE [dbo].[_FormLDRSubcategory] ADD CONSTRAINT FK_FormLDRSubcategory_ldrsubcategory FOREIGN KEY(ldr_subcategory_id) REFERENCES [dbo].LDRSubcategory ([subcategory_id]);

/*
--Justification for FK

select pq.form_id, pq.revision_id
  from FormLDRSubcategory pq
  left join formldr p on pq.form_id = p.form_id and pq.revision_id = p. revision_id
 where (p.form_id is NULL or p.revision_id is Null)
   and pq.form_id IS NOT NULL and pq.revision_id IS NOT NULL
--90,121 rows, implement deferred

select pq.ldr_subcategory_id
  from FormLDRSubcategory pq
  left join ldrsubcategory p on pq.ldr_subcategory_id = p.subcategory_id
 where p.subcategory_id is NULL
   and pq.ldr_subcategory_id IS NOT NULL
--0 rows

*/
-------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormLDR](
    [FormLDR_uid] INTEGER IDENTITY(1,1) NOT NULL,					-- created new column as primary key
	[form_id] INTEGER NOT NULL,
	[revision_id] INTEGER NOT NULL,
	[form_version_id] INTEGER NULL,			
	[customer_id_from_form] INTEGER NULL,
	[customer_id] INTEGER NULL,										-- FK to Customer.customer_id
	[app_id] VARCHAR(20) NULL,
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[company_id] INTEGER NULL,										-- Composite FK to Profitcenter.company_id
	[profit_ctr_id] INTEGER NULL,									-- Composite FK to Profitcenter.profit_ctr_id
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormLDR_created_by] DEFAULT SYSTEM_USER,     	-- Not NULL, varchar(60) -> varchar(100)
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormLDR_date_created] DEFAULT GETDATE(),		-- Not NULL, Default added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormLDR_modified_by] DEFAULT SYSTEM_USER,	-- Not NULL, varchar(60) -> varchar(100), Default added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormLDR_date_modified] DEFAULT GETDATE(),    	-- Not NULL, Default added
	[generator_name] VARCHAR(75) NULL,
	[generator_epa_id] VARCHAR(12) NULL,
	[generator_address1] VARCHAR(40) NULL,
	[generator_city] VARCHAR(40) NULL,
	[generator_state] VARCHAR(2) NULL,
	[generator_zip] VARCHAR(10) NULL,
	[state_manifest_no] VARCHAR(20) NULL,
	[manifest_doc_no] VARCHAR(20) NULL,
	[generator_id] INTEGER NULL,									-- FK to Generator.generator_id
	[generator_address2] VARCHAR(40) NULL,
	[generator_address3] VARCHAR(40) NULL,
	[generator_address4] VARCHAR(40) NULL,
	[generator_address5] VARCHAR(40) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,			-- remove rowguid column
	[wcr_id] INTEGER NULL,											-- Composite FK to FormWCR.form_id
	[wcr_rev_id] INTEGER NULL,										-- Composite FK to FormWCR.revision_id
	[ldr_notification_frequency] CHAR(1) NULL,
	[waste_managed_id] INTEGER NULL,								-- FK to LDRWasteManaged.waste_managed_id
    CONSTRAINT [PK_FormLDR] PRIMARY KEY CLUSTERED ([FormLDR_uid])
)
GO

--new unique constraints
ALTER TABLE dbo._FormLDR WITH CHECK ADD CONSTRAINT UK_FormLDR UNIQUE(form_id, revision_id);

--new foreign keys
ALTER TABLE [dbo].[_FormLDR] ADD CONSTRAINT FK_FormLDR_customer FOREIGN KEY([customer_id]) REFERENCES [dbo].[Customer] ([customer_id]);
ALTER TABLE [dbo].[_FormLDR] ADD CONSTRAINT FK_FormLDR_profitcenter FOREIGN KEY (company_id, profit_ctr_id) REFERENCES [dbo].[Profitcenter] (company_id, profit_ctr_id);
ALTER TABLE [dbo].[_FormLDR] ADD CONSTRAINT FK_FormLDR_generator FOREIGN KEY([generator_id]) REFERENCES [dbo].[Generator] ([generator_id]);
ALTER TABLE [dbo].[_FormLDR] ADD CONSTRAINT FK_FormLDR_formWCR FOREIGN KEY (wcr_id, wcr_rev_id) REFERENCES [dbo].[FormWCR] (form_id, revision_id);
ALTER TABLE [dbo].[_FormLDR] ADD CONSTRAINT FK_FormLDR_LDRWasteManaged FOREIGN KEY([waste_managed_id]) REFERENCES [dbo].[LDRWasteManaged] ([waste_managed_id]);


/*Justification for FK
select pq.customer_id
  from FormLDR pq
  left join customer p on pq.customer_id = p.customer_id
 where p.customer_id IS NULL
   and pq.customer_id IS NOT NULL
--2 rows

select pq.profit_ctr_id, pq.company_id
  from FormLDR pq
  left join profitcenter p on pq.company_id = p.company_id and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id IS NULL or p.profit_ctr_id IS NULL)
   and pq.profit_ctr_id IS NOT NULL and pq.company_id IS NOT NULL
--0 rows

select pq.generator_id
  from FormLDR pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id IS NULL
   and pq.generator_id IS NOT NULL
--14,074 rows

select pq.generator_id, COUNT(pq.generator_id) as CT
  from FormLDR pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id IS NULL
   and pq.generator_id IS NOT NULL
 group by pq.generator_id

generator_id	CT
272340			1
-1				14073

select pq.wcr_id, pq.wcr_rev_id
  from formldr pq
  left join formwcr p on pq.wcr_id = p.form_id and pq.wcr_rev_id = p. revision_id
 where (p.form_id IS NULL or p.revision_id IS Null)
   and pq.wcr_id IS NOT NULL and pq.wcr_rev_id IS NOT NULL
--8640 rows, implement deferred

select pq.waste_managed_id
  from FormLDR pq
  left join LDRWasteManaged p on pq.waste_managed_id = p.waste_managed_id
 where p.waste_managed_id IS NULL
   and pq.waste_managed_id IS NOT NULL
--1207 rows, [waste_managed_id = 0]
*/

/*
--Justification for not null values 
select date_created from FormLDR where date_created is null or date_created = '' 
--0 rows

select date_modified from FormLDR where date_modified is null or date_modified = '' 
--0 rows

select Modified_by from FormLDR where Modified_by is null or Modified_by = '' 
--49,895 rows

select created_by from FormLDR where created_by is null or created_by = '' 
--27,023 rows
*/

-----------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormLDRDetail](
    [FormLDRDetail_uid] INTEGER IDENTITY(1,1) NOT NULL,				-- created new column as primary key
	[form_id] INTEGER NOT NULL,										-- Composite FK to FormLDR.form_id
	[revision_id] INTEGER NOT NULL,									-- Composite FK to FormLDR.revision_id
	[form_version_id] INTEGER NULL,								
	[page_number] INTEGER NULL,
	[manifest_line_item] INTEGER NULL,
	[ww_or_nww] CHAR(3) NULL,
	[subcategory] VARCHAR(80) NULL,
	[manage_id] INTEGER NULL,
	[approval_code] VARCHAR(40) NULL,
	[approval_key] INTEGER NULL,
	[company_id] INTEGER NULL,										-- Composite FK to ProfitCenter.company_id
	[profit_ctr_id] INTEGER NULL,									-- Composite FK to ProfitCenter.profit_ctr_id
	[profile_id] INTEGER NULL,										-- FK to Profile.profile_id
	[constituents_requiring_treatment_flag] CHAR(1) NULL,
    [added_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormLDRDetail_added_by] DEFAULT SYSTEM_USER,		-- added column
    [date_added] DATETIME NOT NULL CONSTRAINT [DF_FormLDRDetail_date_added] DEFAULT GETDATE(),			-- added column                    
    [modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormLDRDetail_modified_by] DEFAULT SYSTEM_USER,  -- added column
    [date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormLDRDetail_modified] DEFAULT GETDATE(),			-- added column  
    CONSTRAINT [PK_FormLDRDetail] PRIMARY KEY CLUSTERED ([FormLDRDetail_uid])
)
GO

--changed the index name from FormLDRDetail_ci to ix_FormLDRDetail
CREATE UNIQUE NONCLUSTERED INDEX IX_FormLDRDetail ON dbo.FormLDRDetail (form_id ASC, revision_id ASC, page_number ASC, manifest_line_item ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormLDRDetail] ADD CONSTRAINT FK_FormLDRDetail_formLDR FOREIGN KEY (form_id,revision_id) REFERENCES [dbo].[FormLDR] (form_id, revision_id);
ALTER TABLE [dbo].[_FormLDRDetail] ADD CONSTRAINT FK_FormLDRDetail_profitcenter FOREIGN KEY (company_id,profit_ctr_id) REFERENCES [dbo].[ProfitCenter] (company_id, profit_ctr_id);
ALTER TABLE [dbo].[_FormLDRDetail] ADD CONSTRAINT FK_FormLDRDetail_profile FOREIGN KEY (profile_id) REFERENCES dbo.[Profile] (profile_id);

/*
--Justification for FK

select pq.form_id, pq.revision_id
  from FormLDRDetail pq
  left join formldr p on pq.form_id = p.form_id and pq.revision_id = p. revision_id
 where (p.form_id IS NULL or p.revision_id IS Null)
   and pq.form_id IS NOT NULL and pq.revision_id IS NOT NULL
--72,298 rows, implement deferred

select pq.profit_ctr_id, pq.company_id
  from FormLDRDetail pq
  left join profitcenter p on pq.company_id = p.company_id and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id is NULL or p.profit_ctr_id is Null)
   and pq.profit_ctr_id IS NOT NULL and pq.company_id IS NOT NULL
--0 rows

select pq.profile_id
  from FormLDRDetail pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id IS NULL
   and pq.profile_id IS NOT NULL
--1 row [profile_id = 406355]
*/

-------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormPQ](
    [FormPQ_uid] INTEGER IDENTITY(1,1) NOT NULL,					-- created new column as primary key
	[form_id] INTEGER NOT NULL,                     
	[revision_id] INTEGER NOT NULL,                 
	[form_version_id] INTEGER NULL,
	[ref_form_id] INTEGER NULL,
	[customer_id] INTEGER NULL,										-- FK to Customer.customer_id
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[preapproval_key] INTEGER NULL,
	[approval_code] VARCHAR(15) NULL,
	[approval_key] INTEGER NULL,
	[company_id] INTEGER NULL,										-- Composite FK to ProfitCenter.company_id
	[profit_ctr_id] INTEGER NULL,									-- Composite FK to ProfitCenter.profit_ctr_id
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormPQ_created_by] DEFAULT SYSTEM_USER,     	-- NOT NULL, varchar(60) -> varchar(100)
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormPQ_date_created] DEFAULT GETDATE(),			-- NOT NULL, Default added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormPQ_modified_by] DEFAULT SYSTEM_USER,		-- NOT NULL, varchar(60) -> varchar(100), Default added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormPQ_date_modified] DEFAULT GETDATE(),    	-- NOT NULL, Default added
	[tracking_id] INTEGER NULL,                   
	[date_form] DATETIME NULL,
	[waste_common_name] VARCHAR(50) NULL,
	[sample_needed] CHAR(1) NULL,
	[MSDS_needed] CHAR(1) NULL,
	[EPA_ID_needed] CHAR(1) NULL,
	[gen_signature_needed] CHAR(1) NULL,
	[waste_code_needed] CHAR(1) NULL,
	[D_code_chart_needed] CHAR(1) NULL,
	[DOT_shipping_name_needed] CHAR(1) NULL,
	[site_history_needed] CHAR(1) NULL,
	[site_map_needed] CHAR(1) NULL,
	[cleanup_plan_needed] CHAR(1) NULL,
	[analysis_needed] CHAR(1) NULL,
	[profile_blank_flag] CHAR(1) NULL,
	[profile_blank_text] varchar(1600) NULL,						--text to varchar(1600)
	[profile_blank_reply] varchar(1000) NULL,						--text to varchar(1000)
	[UHC_flag] CHAR(1) NULL,
	[process_description_flag] CHAR(1) NULL,
	[process_description_detail] CHAR(1) NULL,
	[process_questions_flag] CHAR(1) NULL,
	[process_questions_text] varchar(1200) NULL,					--text to varchar(1200)
	[process_questions_reply] varchar(500) NULL,					--text to varchar(500)
	[necessary_questions_flag] CHAR(1) NULL,
	[necessary_questions_text] varchar(2200) NULL,					--text to varchar(2200)
	[necessary_questions_reply] varchar(500) NULL,					--text to varchar(500)
	[customer_stipulations_flag] CHAR(1) NULL,
	[customer_stipulations_text] varchar(1000) NULL,				--text to varchar(1000)
	[customer_stipulations_reply] varchar(500) NULL,				--text to varchar(500)
	[pendings_resolved_flag] CHAR(1) NULL,
	[pendings_resolved_initials] VARCHAR(10) NULL,
	[pendings_resolved_date] DATETIME NULL,
	[cust_name] VARCHAR(75) NULL,
	[generator_name] VARCHAR(75) NULL,
	[EPA_ID] VARCHAR(12) NULL,
	[generator_id] INTEGER NULL,									-- FK to Generator.generator_id
	[gen_mail_addr1] VARCHAR(40) NULL,
	[gen_mail_addr2] VARCHAR(40) NULL,
	[gen_mail_addr3] VARCHAR(40) NULL,
	[gen_mail_addr4] VARCHAR(40) NULL,
	[gen_mail_addr5] VARCHAR(40) NULL,
	[gen_mail_city] VARCHAR(40) NULL,
	[gen_mail_state] VARCHAR(2) NULL,
	[gen_mail_zip_code] VARCHAR(15) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,			-- remove rowguid column
	[profile_id] INTEGER NULL,										-- FK to Profile.profile_id
    CONSTRAINT [PK_FormPQ] PRIMARY KEY CLUSTERED ([FormPQ_uid])
)

--Existing indexes
CREATE UNIQUE NONCLUSTERED INDEX UK_FormPQ ON dbo.FormPQ ( form_id ASC,	revision_id ASC);
CREATE NONCLUSTERED INDEX IX_FormPQ_ref_form_id ON dbo.FormPQ (ref_form_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormPQ] ADD CONSTRAINT [FK_FormPQ_customer] FOREIGN KEY([customer_id]) REFERENCES [dbo].[_customer] ([customer_id]);
ALTER TABLE [dbo].[_FormPQ] ADD CONSTRAINT FK_FormPQ_profitcenter FOREIGN KEY (company_id,profit_ctr_id) REFERENCES dbo.ProfitCenter (company_id, profit_ctr_id);
ALTER TABLE [dbo].[_FormPQ] ADD CONSTRAINT [FK_FormPQ_generator] FOREIGN KEY([generator_id]) REFERENCES [dbo].[_generator] ([generator_id]);
ALTER TABLE [dbo].[_FormPQ] ADD CONSTRAINT [FK_FormPQ_profile] FOREIGN KEY([profile_id]) REFERENCES [dbo].[_profile] ([profile_id]);

/*
--Justification for FK
select pq.customer_id
  from FormPQ pq
  left join customer p on pq.customer_id = p.customer_id
 where p.customer_id is NULL
   and pq.customer_id IS NOT NULL
--194 rows, [customer_id = 0]

select pq.profit_ctr_id, pq.company_id
  from FormPQ pq
  left join profitcenter p on pq.company_id = p.company_id and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id IS NULL or p.profit_ctr_id IS NULL)
   and pq.profit_ctr_id IS NOT NULL and pq.company_id IS NOT NULL
--0 rows

select pq.generator_id
  from FormPQ pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id IS NULL
   and pq.generator_id IS NOT NULL
--0 rows

select pq.profile_id
  from FormPQ pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id IS NULL
   and pq.profile_id IS NOT NULL
--0 rows
*/

/*
--Justification for not null values 

select * from FormPQ where date_created is null or date_created = '' 
--0 rows

select * from FormPQ where date_modified is null or date_modified = '' 
--0 rows

select * from FormPQ where Modified_by is null or Modified_by = '' 
--4 rows

select * from FormPQ where created_by is null or created_by = '' 
--4 rows
*/

/*
--Length adjustment justifications:

select TOP 5 DATALENGTH([profile_blank_text])
  from FormPQ
 order by DATALENGTH([profile_blank_text]) DESC
--1452, 998, 856, 855, 793

select TOP 5 DATALENGTH([profile_blank_reply])
  from FormPQ
 order by DATALENGTH([profile_blank_reply]) DESC
--793, 162, 157, 112, 76

select TOP 5 DATALENGTH([process_questions_text])
  from FormPQ
 order by DATALENGTH([process_questions_text]) DESC
--1019, 961, 759, 706, 639

select TOP 5 DATALENGTH([process_questions_reply])
  from FormPQ
 order by DATALENGTH([process_questions_reply]) DESC
--322, 139, 132, 132, 119

select TOP 5 DATALENGTH([necessary_questions_text])
  from FormPQ
 order by DATALENGTH([necessary_questions_text]) DESC
--2139, 981, 978, 972, 872

select TOP 5 DATALENGTH([necessary_questions_reply])
  from FormPQ
 order by DATALENGTH([necessary_questions_reply]) DESC
--444, 190, 133, 54, 15

select TOP 5 DATALENGTH([customer_stipulations_text])
  from FormPQ
 order by DATALENGTH([customer_stipulations_text]) DESC
--816, 761, 761, 526, 433

select TOP 5 DATALENGTH([customer_stipulations_reply])
  from FormPQ
 order by DATALENGTH([customer_stipulations_reply]) DESC
--89, 0, 0, 0, 0
*/
--------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormRA](
    [FormRA_uid] INTEGER IDENTITY(1,1) NOT NULL,				-- created new column as primary key
	[form_id] INTEGER NOT NULL,                    
	[revision_id] INTEGER NOT NULL,                
	[form_version_id] INTEGER NULL,
	[customer_id] INTEGER NULL,									-- FK to Customer.customer_id
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[approval_code] VARCHAR(15) NULL,
	[approval_key] INTEGER NULL,
	[company_id] INTEGER NULL,									-- Composite FK to Profitcenter.company_id
	[profit_ctr_id] INTEGER NULL,								-- Composite FK to Profitcenter.profit_ctr_id
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormRA_created_by] DEFAULT SYSTEM_USER,     	-- Not NULL, varchar(60) -> varchar(100)
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormRA_date_created] DEFAULT GETDATE(),			-- Not NULL, Default added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormRA_modified_by] DEFAULT SYSTEM_USER,		-- Not NULL, varchar(60) -> varchar(100), Default added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormRA_date_modified] DEFAULT GETDATE(),    	-- Not NULL, Default added
	[approval_ots_flag] VARCHAR(1) NULL,
	[approval_waste_code] VARCHAR(4) NULL,
	[approval_ap_expiration_date] DATETIME NULL,
	[generator_generator_name] VARCHAR(75) NULL,
	[wastecode_waste_code_desc] VARCHAR(60) NULL,
	[approval_approval_desc] VARCHAR(50) NULL,
	[customer_cust_addr1] VARCHAR(40) NULL,
	[customer_cust_addr2] VARCHAR(40) NULL,
	[customer_cust_addr3] VARCHAR(40) NULL,
	[customer_cust_addr4] VARCHAR(40) NULL,
	[customer_cust_city] VARCHAR(40) NULL,
	[customer_cust_state] VARCHAR(2) NULL,
	[customer_cust_zip_code] VARCHAR(15) NULL,
	[customer_cust_name] VARCHAR(75) NULL,
	[contact_id] INTEGER NULL,									-- FK to Contact.contact_id
	[contact_name] VARCHAR(40) NULL,
	[customer_cust_fax] VARCHAR(20) NULL,
	[generator_id] INTEGER NULL,								-- Fk to Generator.generator_id
	[generator_epa_id] VARCHAR(12) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,		-- remove rowguid column
	[profile_id] INTEGER NULL,									-- FK to Profile.profile_id
	[TAB] FLOAT NULL,
	[benzene] FLOAT NULL,
    CONSTRAINT [PK_FormRA] PRIMARY KEY CLUSTERED ([FormRA_uid])
)
GO

CREATE UNIQUE NONCLUSTERED INDEX UK_FormRA ON dbo.FormRA (form_id ASC, revision_id ASC);
CREATE NONCLUSTERED INDEX IX_FormRA_profile_id ON dbo.FormRA (profile_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormRA] ADD CONSTRAINT [FK_FormRA_customer] FOREIGN KEY([customer_id]) REFERENCES [dbo].[Customer] ([customer_id]);
ALTER TABLE [dbo].[_FormRA] ADD CONSTRAINT FK_FormRA_profitcenter FOREIGN KEY (company_id,profit_ctr_id) REFERENCES [dbo].[Profitcenter] (company_id, profit_ctr_id);
ALTER TABLE [dbo].[_FormRA] ADD CONSTRAINT [FK_FormRA_contact] FOREIGN KEY([contact_id]) REFERENCES [dbo].[Contact] ([contact_id]);
ALTER TABLE [dbo].[_FormRA] ADD CONSTRAINT [FK_FormRA_generator] FOREIGN KEY([generator_id]) REFERENCES [dbo].[Generator] ([generator_id]);
ALTER TABLE [dbo].[_FormRA] ADD CONSTRAINT [FK_FormRA_profile] FOREIGN KEY([profile_id]) REFERENCES [dbo].[Profile] ([profile_id]);


/*Justification for FK
select pq.customer_id
  from FormRA pq
 left join customer p on pq.customer_id = p.customer_id
where p.customer_id is NULL
  and pq.customer_id IS NOT NULL
--0 rows

select pq.profit_ctr_id, pq.company_id
  from FormRA pq
  left join profitcenter p on pq.company_id = p.company_id and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id IS NULL or p.profit_ctr_id IS NULL)
   and pq.profit_ctr_id IS NOT NULL and pq.company_id IS NOT NULL
--0 rows

select pq.contact_id
  from FormRA pq
  left join contact p on pq.contact_id = p.contact_id
 where p.contact_id IS NULL
   and pq.contact_id IS NOT NULL
--15,166 rows

select pq.contact_id, COUNT(pq.contact_id) as CT
  from FormRA pq
  left join contact p on pq.contact_id = p.contact_id
 where p.contact_id IS NULL
   and pq.contact_id IS NOT NULL
 group by pq.contact_id

contact_id	CT
5907		1
213386		2
5545		15
269909		1
0			15147

select pq.generator_id
  from FormRA pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id IS NULL
   and pq.generator_id IS NOT NULL
--0 rows

select pq.profile_id
  from FormRA pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id IS NULL
   and pq.profile_id IS NOT NULL
--0 rows
*/

/*
--Justification for not null values 

select * from FormRA where date_created is null or date_created = '' 
--0 rows

select * from FormRA where date_modified is null or date_modified = '' 
--0 rows

select * from FormRA where Modified_by is null or Modified_by = '' 
--0 rows

select * from FormRA where created_by is null or created_by = '' 
--0 rows
*/

-----------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[_FormSREC](
    [FormSREC_uid] INTEGER IDENTITY(1,1) NOT NULL,					-- created new column as primary key
	[form_id] INTEGER NOT NULL,                     
	[revision_id] INTEGER NOT NULL,                   
	[form_version_id] INTEGER NULL,
	[customer_id_from_form] INTEGER NULL,
	[customer_id] INTEGER NULL,										-- FK to Customer.customer_id
	[app_id] VARCHAR(20) NULL,
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[approval_code] VARCHAR(15) NULL,
	[approval_key] INTEGER NULL,
	[company_id] INTEGER NULL,                        
	[profit_ctr_id] INTEGER NULL,                     
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormSREC_created_by] DEFAULT SYSTEM_USER,    	-- Not NULL, varchar(60) -> varchar(100) modified
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormSREC_date_created] DEFAULT GETDATE(),		-- Not NULL, Default value added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormSREC_modified_by] DEFAULT SYSTEM_USER,	-- Not NULL, varchar(60) -> varchar(100), Default value added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormSREC_date_modified] DEFAULT GETDATE(),    	-- Not NULL, Default value added
	[exempt_id] INTEGER NULL,
	[waste_type] VARCHAR(50) NULL,
	[waste_common_name] VARCHAR(50) NULL,
	[manifest] VARCHAR(20) NULL,
	[cust_name] VARCHAR(75) NULL,
	[generator_name] VARCHAR(75) NULL,
	[EPA_ID] VARCHAR(12) NULL,
	[generator_id] INTEGER NULL,									-- FK to Generator.generator_id
	[gen_mail_addr1] VARCHAR(40) NULL,
	[gen_mail_addr2] VARCHAR(40) NULL,
	[gen_mail_addr3] VARCHAR(40) NULL,
	[gen_mail_addr4] VARCHAR(40) NULL,
	[gen_mail_addr5] VARCHAR(40) NULL,
	[gen_mail_city] VARCHAR(40) NULL,
	[gen_mail_state] VARCHAR(2) NULL,
	[gen_mail_zip_code] VARCHAR(15) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,			-- remove rowguid column
	[profile_id] INTEGER NULL,                        
	[qty_units_desc] VARCHAR(255) NULL,
	[disposal_date] VARCHAR(255) NULL,
	[wcr_id] INTEGER NULL,											-- Composite FK to formWCR.form_id
	[wcr_rev_id] INTEGER NULL,										-- Composite FK to formWCR.revision_id
    CONSTRAINT [PK_FormSREC] PRIMARY KEY CLUSTERED ([FormSREC_uid])
)
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_FormSREC ON dbo.FormSREC (form_id ASC, revision_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_FormSREC] ADD CONSTRAINT FK_FormSREC_customer FOREIGN KEY([customer_id]) REFERENCES [dbo].[_customer] ([customer_id]);
ALTER TABLE [dbo].[_FormSREC] ADD CONSTRAINT FK_FormSREC_generator FOREIGN KEY([generator_id]) REFERENCES [dbo].[_generator] ([generator_id]);
ALTER TABLE [dbo].[_FormSREC] ADD CONSTRAINT FK_FormSREC_formWCR FOREIGN KEY (wcr_id,wcr_rev_id) REFERENCES [dbo].[_formWCR] (form_id, revision_id);

/*
--Justification for FK

select pq.customer_id
  from FormSREC pq
  left join customer p on pq.customer_id = p.customer_id
 where p.customer_id IS NULL
   and pq.customer_id IS NOT NULL
--0 rows

select pq.generator_id
  from FormSREC pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id IS NULL
   and pq.generator_id IS NOT NULL
--0 rows

select pq.wcr_id, pq.wcr_rev_id
  from FormSREC pq
  left join formwcr p on pq.wcr_id = p.form_id and pq.wcr_rev_id = p. revision_id
 where (p.form_id IS NULL or p.revision_id IS Null)
   and pq.wcr_id IS NOT NULL and pq.wcr_rev_id IS NOT NULL
--1292 rows, implement deferred
*/

/*
--Justification for not null values 

select * from FormSREC where date_created is null or date_created = '' 
--0 rows

select * from FormSREC where date_modified is null or date_modified = '' 
--0 rows

select * from FormSREC where Modified_by is null or Modified_by = '' 
--2 rows

select * from FormSREC where created_by is null or created_by = '' 
--2 rows
*/

----------------------------------------------------------------------------------------------------
--skip this table
/*
CREATE TABLE [dbo].[_FormWCR_LDR](
    [FormWCR_LDR_uid] INTEGER IDENTITY(1,1) NOT NULL,    -- created new column as primary key
	[WCR_form_id] INTEGER NOT NULL,
	[WCR_revision_id] INTEGER NOT NULL,
	[LDR_form_id] INTEGER NOT NULL,
	[LDR_revision_id] INTEGER NOT NULL,
	[ww_or_nww] CHAR(3) NULL,
	[subcategory] VARCHAR(40) NULL,
	[manage_method] VARCHAR(40) NULL,
	[manage_id] INTEGER NULL,
	[contains_listed] CHAR(8) NULL,
	[exhibits_characteristic] CHAR(8) NULL,
	[soil_treatment_standards] VARCHAR(13) NULL,
	[group_id] INTEGER NULL,
    added_by VARCHAR(100) NOT NULL CONSTRAINT [DF_FormWCR_LDR_added_by] DEFAULT SYSTEM_USER,              -- Added column
    date_added DATETIME NOT NULL CONSTRAINT [DF_FormWCR_LDR_date_added] DEFAULT GETDATE(),                -- Added column
	modified_by VARCHAR(100) NOT NULL CONSTRAINT [DF_FormWCR_LDR_modified_by] DEFAULT SYSTEM_USER,        -- Added column
    date_modified DATETIME NOT NULL CONSTRAINT [DF_FormWCR_LDR_date_modified] DEFAULT GETDATE(),          -- Added column
    CONSTRAINT [PK_FormWCR_LDR] PRIMARY KEY CLUSTERED ([FormWCR_LDR_uid])
)
GO
*/

-----------------------------------------------------------------------------------------
-- skip this table
/*
CREATE TABLE [dbo].[_FormWWA](
    [FormWWA_uid] INTEGER IDENTITY(1,1) NOT NULL,					-- created new column as primary key
	[form_id] INTEGER NOT NULL,
	[revision_id] INTEGER NOT NULL,
	[form_version_id] INTEGER NULL,
	[customer_id_from_form] INTEGER NULL,
	[customer_id] INTEGER NULL,										-- FK to Customer.customer_id
	[app_id] VARCHAR(20) NULL,
	[status] CHAR(1) NOT NULL,
	[locked] CHAR(1) NOT NULL,
	[source] CHAR(1) NULL,
	[approval_code] VARCHAR(15) NULL,
	[approval_key] INTEGER NULL,
	[company_id] INTEGER NULL,										-- Composite FK to ProfitCenter.company_id
	[profit_ctr_id] INTEGER NULL,									-- Composite FK to ProfitCenter.profit_ctr_id
	[signing_name] VARCHAR(40) NULL,
	[signing_company] VARCHAR(40) NULL,
	[signing_title] VARCHAR(40) NULL,
	[signing_date] DATETIME NULL,
	[created_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormWWA_created_by] DEFAULT SYSTEM_USER,     	-- Not NULL, varchar(60) -> varchar(100) modified
	[date_created] DATETIME NOT NULL CONSTRAINT [DF_FormWWA_date_created] DEFAULT GETDATE(),		-- Not NULL, Default value added
	[modified_by] VARCHAR(100) NOT NULL CONSTRAINT [DF_FormWWA_modified_by] DEFAULT SYSTEM_USER,	-- Not NULL, varchar(60) -> varchar(100), Default value added
	[date_modified] DATETIME NOT NULL CONSTRAINT [DF_FormWWA_date_modified] DEFAULT GETDATE(),    	-- Not NULL, Default value added
	[generator_name] VARCHAR(75) NULL,
	[waste_common_name] VARCHAR(50) NULL,
	[info_basis] VARCHAR(10) NULL,
	[bis_phthalate_flag] CHAR(1) NULL,
	[bis_phthalate_actual] FLOAT NULL,
	[carbazole_flag] CHAR(1) NULL,
	[carbazole_actual] FLOAT NULL,
	[o_cresol_flag] CHAR(1) NULL,
	[o_cresol_actual] FLOAT NULL,
	[p_cresol_flag] CHAR(1) NULL,
	[p_cresol_actual] FLOAT NULL,
	[n_decane_flag] CHAR(1) NULL,
	[n_decane_actual] FLOAT NULL,
	[fluoranthene_flag] CHAR(1) NULL,
	[fluoranthene_actual] FLOAT NULL,
	[n_octadecane_flag] CHAR(1) NULL,
	[n_octadecane_actual] FLOAT NULL,
	[trichlorophenol_246_flag] CHAR(1) NULL,
	[trichlorophenol_246_actual] FLOAT NULL,
	[phosphorus_flag] CHAR(1) NULL,
	[phosphorus_actual] FLOAT NULL,
	[total_chlor_phen_flag] CHAR(1) NULL,
	[total_chlor_phen_actual] FLOAT NULL,
	[total_organic_actual] FLOAT NULL,
	[pcb_flag] CHAR(1) NULL,
	[pcb_actual] FLOAT NULL,
	[acidity_flag] CHAR(1) NULL,
	[acidity_actual] FLOAT NULL,
	[fog_flag] CHAR(1) NULL,
	[fog_actual] FLOAT NULL,
	[tss_flag] CHAR(1) NULL,
	[tss_actual] FLOAT NULL,
	[bod_flag] CHAR(1) NULL,
	[bod_actual] FLOAT NULL,
	[antimony_flag] CHAR(1) NULL,
	[antimony_actual] FLOAT NULL,
	[arsenic_flag] CHAR(1) NULL,
	[arsenic_actual] FLOAT NULL,
	[cadmium_flag] CHAR(1) NULL,
	[cadmium_actual] FLOAT NULL,
	[chromium_flag] CHAR(1) NULL,
	[chromium_actual] FLOAT NULL,
	[cobalt_flag] CHAR(1) NULL,
	[cobalt_actual] FLOAT NULL,
	[copper_flag] CHAR(1) NULL,
	[copper_actual] FLOAT NULL,
	[cyanide_flag] CHAR(1) NULL,
	[cyanide_actual] FLOAT NULL,
	[iron_flag] CHAR(1) NULL,
	[iron_actual] FLOAT NULL,
	[lead_flag] CHAR(1) NULL,
	[lead_actual] FLOAT NULL,
	[mercury_flag] CHAR(1) NULL,
	[mercury_actual] FLOAT NULL,
	[nickel_flag] CHAR(1) NULL,
	[nickel_actual] FLOAT NULL,
	[silver_flag] CHAR(1) NULL,
	[silver_actual] FLOAT NULL,
	[tin_flag] CHAR(1) NULL,
	[tin_actual] FLOAT NULL,
	[titanium_flag] CHAR(1) NULL,
	[titanium_actual] FLOAT NULL,
	[vanadium_flag] CHAR(1) NULL,
	[vanadium_actual] FLOAT NULL,
	[zinc_flag] CHAR(1) NULL,
	[zinc_actual] FLOAT NULL,
	[method_8240] CHAR(1) NULL,
	[method_8270] CHAR(1) NULL,
	[method_8080] CHAR(1) NULL,
	[method_8150] CHAR(1) NULL,
	[used_oil] CHAR(1) NULL,
	[oil_mixed] CHAR(1) NULL,
	[halogen_gt_1000] CHAR(1) NULL,
	[halogen_source] CHAR(10) NULL,
	[halogen_source_desc1] VARCHAR(100) NULL,
	[other_desc_1] VARCHAR(100) NULL,
	[cust_name] VARCHAR(75) NULL,
	[EPA_ID] VARCHAR(12) NULL,
	[generator_id] INTEGER NULL,									-- FK to Generator.generator_id
	[gen_mail_addr1] VARCHAR(40) NULL,
	[gen_mail_addr2] VARCHAR(40) NULL,
	[gen_mail_addr3] VARCHAR(40) NULL,
	[gen_mail_addr4] VARCHAR(40) NULL,
	[gen_mail_addr5] VARCHAR(40) NULL,
	[gen_mail_city] VARCHAR(40) NULL,
	[gen_mail_state] VARCHAR(2) NULL,
	[gen_mail_zip_code] VARCHAR(15) NULL,
	[profitcenter_epa_id] VARCHAR(12) NULL,
	[profitcenter_profit_ctr_name] VARCHAR(50) NULL,
	[profitcenter_address_1] VARCHAR(40) NULL,
	[profitcenter_address_2] VARCHAR(40) NULL,
	[profitcenter_address_3] VARCHAR(40) NULL,
	[profitcenter_phone] VARCHAR(14) NULL,
	[profitcenter_fax] VARCHAR(14) NULL,
	--[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,			-- remove rowguid column
	[profile_id] INTEGER NULL,										-- FK to Profile.profile_id
    CONSTRAINT [PK_FormWWA] PRIMARY KEY CLUSTERED ([FormWWA_uid])
)
GO

CREATE UNIQUE NONCLUSTERED INDEX UK_FormWWA ON dbo.FormWWA (form_id ASC, revision_id ASC);
CREATE NONCLUSTERED INDEX IX_FormWWA_generator_id ON dbo.FormWWA (generator_id ASC);

--new foreign keys
ALTER TABLE [dbo].[_Formwwa] ADD  CONSTRAINT [FK_Formwwa_customer] FOREIGN KEY([customer_id]) REFERENCES [dbo].[_customer] ([customer_id]);
ALTER TABLE [dbo].[_Formwwa] ADD CONSTRAINT FK_Formwwa_profitcenter FOREIGN KEY (company_id,profit_ctr_id) REFERENCES [dbo].[_profitcenter] (company_id, profit_ctr_id);
ALTER TABLE [dbo].[_Formwwa] ADD  CONSTRAINT [FK_Formwwa_generator] FOREIGN KEY([generator_id]) REFERENCES [dbo].[_generator] ([generator_id]);
ALTER TABLE [dbo].[_Formwwa] ADD  CONSTRAINT [FK_Formwwa_profile] FOREIGN KEY([profile_id]) REFERENCES [dbo].[_profile] ([profile_id]);
*/
/*
--Justification for FK
select pq.customer_id
  from Formwwa pq
  left join customer p on pq.customer_id = p.customer_id
 where p.customer_id IS NULL
   and pq.customer_id IS NOT NULL
--0 rows

select pq.profit_ctr_id, pq.company_id
  from Formwwa pq
  left join profitcenter p on pq.company_id = p.company_id and pq.profit_ctr_id = p. profit_ctr_id
 where (p.company_id IS NULL or p.profit_ctr_id IS NULL)
   and pq.profit_ctr_id IS NOT NULL and pq.company_id IS NOT NULL
--0 rows

select pq.generator_id
  from Formwwa pq
  left join generator p on pq.generator_id = p.generator_id
 where p.generator_id IS NULL
   and pq.generator_id IS NOT NULL
--0 rows

select pq.profile_id
  from Formwwa pq
  left join profile p on pq.profile_id = p.profile_id
 where p.profile_id IS NULL
   and pq.profile_id IS NOT NULL
--0 rows
*/

/*
--Justification for not null values 

select * from Formwwa where date_created is null or date_created = '' 
--0 rows

select * from Formwwa where date_modified is null or date_modified = '' 
--0 rows

select * from Formwwa where Modified_by is null or Modified_by = '' 
--0 rows

select * from Formwwa where created_by is null or created_by = '' 
--0 rows
*/
