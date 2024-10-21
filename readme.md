Category 1  : Technical Design Documentation
    
        Input_file: .Txt/.sql/ .zip(.txt/.sql)
        Used_tools: 
                    common_tool: file_read(),chunking()
                    specific_tool: generate_tdd()
                    output_tool (to generate doc file) 
        Output_file: TDD_Documentation.doc 
        
--------------------------------------------------------
    
Category 2  : Identify tables and joins
    
        Input_file: .Txt/.sql/ .zip(.txt/.sql)
        Used_tools: 
                    common_tool: file_read()
                    specific_tool: identify_table_and_joins()
                    output_tool (to generate csv file) 
        Output_file: imapct_analysis.csv

--------------------------------------------------------

Category 3 : Impact Analysis

        Input_file: .txt/.zip
        Used_tools:
                     common_tool: file_read()
                     specific_tool: identify_table_and_joins()
                     output_tool (to generate csv,xlsx,doc file)
        Output_file: 
                     1:employees_impact_sp_and_views.xlsx
                     2:employees_table_analysis.csv
                     3:Impact_analysis_employees_Document

---------------------------------------------------------------
