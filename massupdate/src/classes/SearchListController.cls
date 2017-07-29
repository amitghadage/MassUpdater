/**
 * Class description :
 * Methods in this class creates query based on input.
 * returns queried data and update records based on new values.
 * @author : Amit Ghadage
 * @date : 2017/06/16
 */
public with sharing class SearchListController {
  
  @AuraEnabled
  public static paginationWrapper SarchSObjectList(String sobjectName, String SearchTerm, String fieldsSelected,
                                                     String lookupFieldName, boolean prev, boolean next, String offs)
  {
    System.debug('select count() from '+sobjectName);
    paginationWrapper pw = new paginationWrapper();
    List<SObjectWrapper> sobjectSearchedWrapper = new List<SObjectWrapper>();
     // Create Query String for dynamic soql
    String queryString = 'Select ';
    
    if(fieldsSelected == null)
    return null;
    // if lookup field is not selected then we will add that
    List<String> fieldsList = fieldsSelected.split(';');
    Set<String> tempSet = new Set<String>(fieldsList);
    if(!tempSet.Contains(lookupFieldName))
    fieldsList.add(lookupFieldName);
    
    for(String fieldName : fieldsList)
    {
        queryString +=  ' '+fieldName+',';
    }
    queryString = queryString.subStringBeforeLast(',');
    queryString += ' from '+sobjectName;
    System.debug('SearchTerm : '+SearchTerm);
    String whereClause;
    if(SearchTerm != 'null' && searchTerm != null)
    {
        whereClause =' Where ';
        
        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sobjectName);
        for(Schema.SObjectField sof : convertType.getDescribe().fields.getMap().Values())
            {
                if(sof.getDescribe().getType() != schema.displaytype.reference &&
                sof.getDescribe().getType() != schema.displaytype.TextArea)
                {
                    if(sof.getDescribe().getType() == schema.displaytype.String && sof.getDescribe().getName()!='MilestoneStatus')
                    whereClause += sof.getDescribe().getName()+' LIKE \'%'+searchTerm+'%\' OR ';
                    else if(sof.getDescribe().getType() == schema.displaytype.Picklist)
                    whereClause += sof.getDescribe().getName()+' = \''+searchTerm+'\' OR ';
                }
            }
        
    }
     if(whereClause != null)
    {
        whereClause = whereClause.subStringBeforeLast('OR ');
        queryString = queryString + whereClause;
    }
    
    Integer pageSize = 3;
     Integer totoalRecords;
     if(whereClause != null)
      {
        System.debug('select count() from '+sobjectName+whereClause);
        totoalRecords = Database.countQuery('select count() from '+sobjectName+whereClause);
      }
      else
      totoalRecords = Database.countQuery('select count() from '+sobjectName);
     Integer offset = 0;
     if(prev != null && offs != null && next != null)
     {
        
        
        offset = Integer.valueOf(offs);
        if(pageSize == null)
            pageSize = 3;
        if(prev && offset>0)
            offset -= pageSize;
        if(next && (offset+pagesize)<=totoalRecords) 
            offset += pageSize;        
        
     }
     
    queryString += ' LIMIT '+pageSize+' OFFSET '+offset;
    System.debug(queryString);
    
    // Headers in display list
    SObjectWrapper headers = new SObjectWrapper();
    headers.field1 = fieldsList.Size() > 0? fieldsList.get(0) : 'Field1';
    headers.field2 = fieldsList.Size() > 1? fieldsList.get(1) : 'Field2';
    headers.field3 = fieldsList.Size() > 2? fieldsList.get(2) : 'Field3';
    headers.field4 = fieldsList.Size() > 3? fieldsList.get(3) : 'Field4';
    headers.field5 = fieldsList.Size() > 4? fieldsList.get(4) : 'Field5';
    sobjectSearchedWrapper.add(headers);
    
    for(SObject so : database.query(queryString))
    {
        SObjectWrapper tempRecord = new SObjectWrapper();
        String jsonString = json.serialize(so);
        tempRecord.recordId = getFieldValueFromJson(jsonString, 'Id');
        tempRecord.checkBox = false;
        tempRecord.field1 = getFieldValueFromJson(jsonString, headers.field1);
        tempRecord.field2 = getFieldValueFromJson(jsonString, headers.field2);
        tempRecord.field3 = getFieldValueFromJson(jsonString, headers.field3);
        tempRecord.field4 = getFieldValueFromJson(jsonString, headers.field4);
        tempRecord.field5 = getFieldValueFromJson(jsonString, headers.field5);
        sobjectSearchedWrapper.add(tempRecord); 
        System.debug('tempRecord.recordId :'+tempRecord.recordId);
        
    }   
    System.debug('sobjectSearchedWrapper :'+sobjectSearchedWrapper);
       if(offset + pageSize < totoalRecords)
            pw.hasNext = false;
        else
            pw.hasNext = true;
        if(offset > 0)
            pw.hasPrev = false;
        else
            pw.hasPrev = true;
         pw.offset  = String.ValueOf(offset);
        pw.SObjectWrapperList = sobjectSearchedWrapper;
        System.debug('pw.hasNext :'+pw.hasNext);
        System.debug('pw.hasPrev :'+pw.hasPrev);
    return pw;
     
  }
  
   private static String getFieldValueFromJson(String jsonString, String fieldName)
    {
        fieldName = '\"'+fieldName+'\":\"';
        jsonString = jsonString.SubStringAfter(fieldName);
        jsonString= jsonString.subStringBefore('\"');
        return jsonString;  
    }
    
    @auraEnabled
    public static String assignLookups(String sobjectWrapperList, String lookUpId, String lookupFieldName, String objectName)
    {
        System.debug('lookupFieldName :'+lookupFieldName);
        System.debug('objectName :'+objectName);
        System.debug('sobjectWrapperList :'+sobjectWrapperList);
        List<SearchListController.SObjectWrapper> lstRecords = 
            (List<SearchListController.SObjectWrapper>)
            System.JSON.deserialize(sobjectWrapperList ,List<SearchListController.SObjectWrapper>.class);
        Integer i = 0;
        List<sobject> temp = new List<sobject>();
        for(SearchListController.SObjectWrapper sw : lstRecords)
        {
            System.debug('sw.recordId :'+sw.recordId);
            System.debug('sw.checkBox :'+sw.checkBox);
            String jsonString = json.serialize((object)sw);
            //String s = '{"attributes":{"type":"Case","url":"/services/data/v40.0/sobjects/Case/5007F0000029YdyQAE"},"Id":"5007F0000029YdyQAE","CaseNumber":"00001009","Subject":"test subject"}';
            if(sw.checkBox == true)
            {
                
                jsonString = '{"attributes":{"type":"'+objectName+'","url":"/services/data/v40.0/sobjects/'+objectName+'/'+sw.recordId+'"},"Id":"'+sw.recordId+'","'+lookupFieldName+'":"'+lookUpId+'"}';
                
                // '{\"'+objectName+'\":{\"'+lookupFieldName+'\":\"'+lookUpId+'\"   ,\"Id\":\"'+sw.recordId+'\" }}';
                System.debug('jsonString :'+jsonString);
                object so = Json.deserialize(jsonString, sobject.class);
                temp.add((sobject)so);
        
            }
                    
        }
        try
        {
            update temp;    
        }
        catch(DMLException e)
        {
            return 'FAILED';
        }
        
        return 'SUCCESS';
    }
  
  public class SObjectWrapper{
    @AuraEnabled
    public Boolean checkBox {get; set;}
    @AuraEnabled
    public Id recordId {get; set;} 
    @AuraEnabled
    public String field1 {get; set;}
    @AuraEnabled
    public String field2 {get; set;}
    @AuraEnabled
    public String field3 {get; set;}
    @AuraEnabled
    public String field4 {get; set;}
    @AuraEnabled
    public String field5 {get; set;}
  }
  public class paginationWrapper{
        @AuraEnabled
        public List<SObjectWrapper> SObjectWrapperList;
        @AuraEnabled 
        public boolean hasNext;
        @AuraEnabled 
        public boolean hasPrev;
        @AuraEnabled 
        public String offset;
  }  
}