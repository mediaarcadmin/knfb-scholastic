require 'rake/clean'

SOURCE_DIRECTORY = "./Shared/Libraries/WSDL2ObjC/"

LIBRE_ACCESS_WSDL_URL = "http://laesb.uat.cld.libredigital.com/services/LibreAccessService_1_2_0?wsdl"
LIBRE_ACCESS_WSDL_NAME = "LibreAccessService_UAT.wsdl"
LIBRE_ACCESS_XSD_URL = "http://laesb.uat.cld.libredigital.com/services/LibreAccessService_1_2_0?xsd=types_1_2_0.xsd"
LIBRE_ACCESS_XSD_NAME = "types_1_2_0.xsd"
SCHWS_AUTHENTICATE_WSDL_URL = "https://esvcsqa2.scholastic.com/SchWS/services/SPS/Authenticate?wsdl"
SCHWS_AUTHENTICATE_WSDL_NAME = "SchWS_Authenticate_QA.wsdl"
SCHWS_GETUSERINFO_WSDL_URL = "https://esvcsqa2.scholastic.com/SchWS/services/SPS/GetUserInfo?wsdl"
SCHWS_GETUSERINFO_WSDL_NAME = "SchWS_GetUserInfo_QA.wsdl"
SCHWS_WISHLIST_WSDL_URL = "https://esvcsqa2.scholastic.com/SchWS/services/SPS/WishListService?wsdl"
SCHWS_WISHLIST_WSDL_NAME = "SchWS_WishListService_QA.wsdl"

task :default => ["diff_qa_libre_access_wsdl"]

desc "Fetch all the QA WSDL files"
task :fetch_all_qa_wsdls => ["fetch_qa_libre_access_wsdl", "fetch_qa_scholastic_authenticate_wsdl", "fetch_qa_scholastic_getuserinfo_wsdl", "fetch_qa_scholastic_wishlist_wsdl"]

desc "Diff all the QA WSDL files"
task :diff_all_qa_wsdls => ["diff_qa_libre_access_wsdl", "diff_qa_scholastic_authenticate_wsdl", "diff_qa_scholastic_getuserinfo_wsdl", "diff_qa_scholastic_wishlist_wsdl"]

desc "Fetch the UAT Libre Access WSDL file"
task :fetch_qa_libre_access_wsdl do |t|
  fetch(LIBRE_ACCESS_WSDL_URL, LIBRE_ACCESS_WSDL_NAME)
  fetch(LIBRE_ACCESS_XSD_URL, LIBRE_ACCESS_XSD_NAME)
end

desc "Fetch the QA Scholastic Authenticate WSDL file"
task :fetch_qa_scholastic_authenticate_wsdl do |t|
    fetch(SCHWS_AUTHENTICATE_WSDL_URL, SCHWS_AUTHENTICATE_WSDL_NAME)
end

desc "Fetch the QA Scholastic GetUserInfo WSDL file"
task :fetch_qa_scholastic_getuserinfo_wsdl do |t|
    fetch(SCHWS_GETUSERINFO_WSDL_URL, SCHWS_GETUSERINFO_WSDL_NAME)  
end

desc "Fetch the QA Scholastic WishList WSDL file"
task :fetch_qa_scholastic_wishlist_wsdl do |t|
    fetch(SCHWS_WISHLIST_WSDL_URL, SCHWS_WISHLIST_WSDL_NAME)    
end

desc "Diff the UAT Libre Access WSDL file with the online version"
task :diff_qa_libre_access_wsdl do |t|
  diff(LIBRE_ACCESS_WSDL_URL, LIBRE_ACCESS_WSDL_NAME)
  diff(LIBRE_ACCESS_XSD_URL, LIBRE_ACCESS_XSD_NAME)
end

desc "Diff the QA Scholastic Authenticate WSDL file with the online version"
task :diff_qa_scholastic_authenticate_wsdl do |t|
  diff(SCHWS_AUTHENTICATE_WSDL_URL, SCHWS_AUTHENTICATE_WSDL_NAME)
end

desc "Diff the Scholastic GetUserInfo WSDL file with the online version"
task :diff_qa_scholastic_getuserinfo_wsdl do |t|
  diff(SCHWS_GETUSERINFO_WSDL_URL, SCHWS_GETUSERINFO_WSDL_NAME)  
end

desc "Diff QA Scholastic WishList WSDL file with the online version"
task :diff_qa_scholastic_wishlist_wsdl do |t|
  diff(SCHWS_WISHLIST_WSDL_URL, SCHWS_WISHLIST_WSDL_NAME)    
end

def fetch url, filename
  `curl #{url} -o #{SOURCE_DIRECTORY+filename}`
end

def diff url, filename
  sh %{curl -s #{url} | diff #{SOURCE_DIRECTORY+filename} - > /dev/null} do |ok, res|
    case res.exitstatus
      when 0 
        puts "no updates #{url}"
      when 1 
        puts "UPDATED!!! #{url}"
      else 
        puts "Command failed with status (#{res.exitstatus})"        
      end
  end
end
