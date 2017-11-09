#
# Cookbook:: webapp-windows
# Recipe:: database
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#Install SQL Server
include_recipe 'sql_server::server'

#Create database, table and customer database
#Create a path to create-database.sql in Chef cache
create_database_script_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'create-database.sql'))

#Copy create-database.sql from cookbook to chef cache
cookbook_file create_database_script_path do
    source 'create-database.sql'
end

#Get path to SQL Server PowerShell module
sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')

#Run the SQL file, but only if leanrchef database has not been created
powershell_script 'Initialize database' do
    code <<-EOH
    Import-Module "#{sqlps_module_path}" 
    Invoke_Sqlcmd -InputFile #{create_database_script_path}
    EOH
    gaurd_interpreter :powershell_script
    only_if <<-EOH
    Import-Module "#{sqlps_module_path}"
    (Invoke-Sqlcmd -Query "SELECT COUNT(*) AS Count FROM sys.databases WHERE name = 'learnchef'").Count -eq 0
    EOH
end
