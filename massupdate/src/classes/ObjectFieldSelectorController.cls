/**
 * Class description :
 * Methods in this class provides object names, fields given object
 * as picklist to ObjectFieldSelectorComponent
 *
 * @author : Amit Ghadage
 * @date : 2017/06/09
 */
public class ObjectFieldSelectorController {
     @AuraEnabled
    public static List<SelectOption>  getAllSobjects() {
  		 List<SelectOption> selectOptionSobjects = new List<SelectOption>();
         selectOptionSobjects.add(new SelectOption('--None--','--None--'));
      	 for(Schema.sObjectType so : Schema.getGlobalDescribe().values())
      	 {
      	 	if(!so.getDescribe().isCustomSetting() && so.getDescribe().isUpdateable())
      	 	selectOptionSobjects.add(new SelectOption(so.getDescribe().getLabel(), so.getDescribe().getName()));
      	 }
      	 System.debug('selectOptionSobjects :'+selectOptionSobjects);
      	 return selectOptionSobjects;
    }
    private static String getFieldValueFromJson(String jsonString, String fieldName)
    {
    	fieldName = fieldName+'\":\"';
		jsonString = jsonString.SubStringAfter(fieldName);
		jsonString= jsonString.subStringBefore('\"');
		return jsonString;	
    }
    @auraEnabled
    public static List<SelectOption> getFieldsofObject(String objectName, String fieldType)
    {
    	System.debug('beginning of function :'+objectName);
    	List<SelectOption> lookupFieldNames = new List<SelectOption>();
    	lookupFieldNames.add(new SelectOption('--None--','--None--'));
		Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
		for(Schema.SObjectField sof : convertType.getDescribe().fields.getMap().Values())
    	 	{
    	 		if(fieldType == 'Updateable' && sof.getDescribe().isUpdateable())
    	 		{
    	 			lookupFieldNames.add(new SelectOption(sof.getDescribe().getLabel(), sof.getDescribe().getName()));
    	 		}
    	 		else
    	 		if(fieldType == 'Readable' && sof.getDescribe().isAccessible())
    	 		{
    	 			lookupFieldNames.add(new SelectOption(sof.getDescribe().getLabel(), sof.getDescribe().getName()));
    	 		}
    	 	}
    	 	
    	 	return lookupFieldNames;
    }
    
     @auraEnabled
    public static List<SelectOption> getAllFieldsOfsObject(String objectName)
    {
 
    	List<SelectOption> lookupFieldNames = new List<SelectOption>();
		Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectName);
		for(Schema.SObjectField sof : convertType.getDescribe().fields.getMap().Values())
    	 	{
    	 			lookupFieldNames.add(new SelectOption(sof.getDescribe().getLabel(), sof.getDescribe().getName()));
    	 	}
    	 	System.debug('lookupFieldNames :'+lookupFieldNames);
    	 	return lookupFieldNames;
    }
    
    public class SelectOption{
    	@AuraEnabled
    	public String label {get; set;}
    	@AuraEnabled
    	public String value {get; set;}
    	public SelectOption(String label, String value)
    	{
    		this.label = label;
    		this.value = value;
    	}
    }
}