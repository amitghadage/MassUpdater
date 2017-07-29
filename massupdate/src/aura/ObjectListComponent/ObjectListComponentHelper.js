({
	handleFieldSelectedValueAddedEventHelper : function(component, event, helper) {
		console.log('Event Parameters :'+event.getParam("ObjectName"));
		console.log(event.getParam("LookupObjectName"));
		console.log(event.getParam("LookupId"));
		console.log(event.getParam("sobjectFieldListSelected"));
		component.set("v.objectName", event.getParam("ObjectName"));
		component.set("v.lookupFieldName", event.getParam("LookupObjectName"));
		component.set("v.newLookupValue", event.getParam("LookupId"));
		component.set("v.sobjectFieldListSelected", event.getParam("sobjectFieldListSelected"));
		
		var action = component.get("c.SarchSObjectList");
		action.setParams({sobjectName : event.getParam("ObjectName"), SearchTerm : 'null',
		 fieldsSelected : event.getParam("sobjectFieldListSelected"), lookupFieldName : event.getParam("LookupObjectName"),
		 objectName : event.getParam("ObjectName")});
		 action.setCallback(this, function(res){
		 var state = res.getState();
         if(state == "SUCCESS")
         {
        	 console.log('result from search function : '+res.getReturnValue().SObjectWrapperList);
        	 component.set("v.PaginationWrapper", res.getReturnValue());
        	
         }
		 });
		 $A.enqueueAction(action);
		 
		
	},
	
	assignReverseLookupHelper : function(cmp, event, helper)
	{
		var action = cmp.get("c.assignLookups");
		var searchResult = cmp.get("v.PaginationWrapper.SObjectWrapperList");
		console.log('searchResult :'+searchResult);
		var processRecords = JSON.stringify(searchResult);
		console.log('processRecords :'+processRecords);
		var tostMessage = '';
		action.setParams({sobjectWrapperList : processRecords , lookUpId : cmp.get("v.newLookupValue"),
		lookupFieldName : cmp.get("v.lookupFieldName"), objectName : cmp.get("v.objectName") });
		action.setCallback(this, function(res){
			if(res.getState() == 'SUCCESS')
			{
				console.log('processed record count :'+res.getReturnValue());
				tostMessage = res.getReturnValue();
                helper.findSobjectsHelper(cmp, event, helper);
                console.log('tostMessage :'+tostMessage)
		 var toastEvent = $A.get("e.force:showToast");
		 if(tostMessage == 'SUCCESS')
		 {
			 toastEvent.setParams({
        "title": "Success!",
        "message": "The record has been updated successfully."
		 });
		 }
		 else
		 {
			 toastEvent.setParams({
        "title": "Failure!",
        "message": "Oops!! Something went wrong."
		 });
		 }
		 
		 toastEvent.fire(); 
			}
		})
		$A.enqueueAction(action);
       
		// Comment show test while testing in console it works in LEX only. 
		
	},
	
	findSobjectsHelper : function(cmp, event, helper)
	{
			 var action = cmp.get("c.SarchSObjectList");
			 action.setParams({sobjectName : cmp.get("v.objectName"), SearchTerm : cmp.find("inputSearch").get("v.value"),
			 fieldsSelected : cmp.get("v.sobjectFieldListSelected"), lookupFieldName : cmp.get("v.lookupFieldName")});
			 action.setCallback(this, function(res){
			 var state = res.getState();
	         if(state == "SUCCESS")
	         {
	        	 console.log('ren : '+res.getReturnValue());
	        	 cmp.set("v.PaginationWrapper", res.getReturnValue());
	        	 cmp.set("v.offset", '0');
	         }
			 });
			 $A.enqueueAction(action);
			
	},
	
	 paginationaHelper : function(component, prevVar, nextVar) {
		 	var action = component.get("c.SarchSObjectList");
		 	var offsetVar = component.get("v.offset");
		 	offsetVar = offsetVar || 0;
		 	console.log('component.find("inputSearch").get("v.value") :'+component.find("inputSearch").get("v.value"));
		 	var searchTermVar;
		 	if(component.find("inputSearch").get("v.value") == null)
		 	searchTermVar = 'null';
		 	else
		 	searchTermVar = component.find("inputSearch").get("v.value");
		 	action.setParams({sobjectName : component.get("v.objectName"), SearchTerm : searchTermVar,
			 fieldsSelected : component.get("v.sobjectFieldListSelected"), lookupFieldName : component.get("v.lookupFieldName"),
			 "prev":prevVar, "next" :nextVar, "offs" :offsetVar});
          action.setCallback(this, function(res) {
         var state = res.getState(); 
             if (state === "SUCCESS") {
                 var result = res.getReturnValue();
                component.set("v.hasPrev", result.hasPrev);
                 component.set("v.hasNext", result.hasNext);
                 component.set("v.PaginationWrapper", result);
                 component.set("v.offset", result.offset);
             }
          });
           $A.enqueueAction(action); 
 }
	
})