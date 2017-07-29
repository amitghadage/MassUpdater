({
	setSobjectList : function(component)
	{
		var action = component.get("c.getAllSobjects");
		action.setCallback(this, function(result)
		{
			component.set("v.sObjectList", result.getReturnValue());
		});
		$A.enqueueAction(action);
	},
	getAllLookups : function(component) {
		console.log('inside action helper');
		var sObjectSelected  = component.find("selected_object").get("v.value");
        if (sObjectSelected == '--None--')
            return;
		var action = component.get("c.getFieldsofObject");
		action.setParams({objectName : sObjectSelected, fieldType : 'Updateable'});
		action.setCallback(this, function(result) {		
		var state = result.getState();
        if(state == "SUCCESS")
        {
            	component.set("v.sObjectLookupFieldList", result.getReturnValue());
            	console.log('result.getReturnValue() :'+result.getReturnValue());
            	if(result.getReturnValue().length > 0)
            	component.set("v.lookupFieldSelected", result.getReturnValue()[0].label);
            	
            	component.set("v.objectSelected", sObjectSelected);
            	
		}
		else
		{
			console.log('error');
		}
		});
		
		var action2 = component.get("c.getFieldsofObject");
		action2.setParams({objectName : sObjectSelected , fieldType : 'Readable'});
		action2.setCallback(this, function(result){
		component.set("v.sObjectFieldList", result.getReturnValue());
		console.log('result.getReturnValue() :'+result.getReturnValue());
		});
		$A.enqueueAction(action);
		$A.enqueueAction(action2);
		console.log('sObjectSelected :'+sObjectSelected);
	},
	
	getRLookupObjectList : function(component, event)
	{
		var allFeildSelected = $A.get("e.c:FieldSelectedValueAdded");
		 var selectedLookupField = component.find("selected_Lookup_Field").get("v.value");
		if(selectedLookupField.length === 0)
		 {
			 selectedLookupField = component.get("v.sObjectLookupFieldList");
			 if(selectedLookupField != 'undefined' && selectedLookupField[0] != 'undefined' && selectedLookupField != '')
			 selectedLookupField = selectedLookupField[0].value;
			 else
			 return;
			 console.log('selectedLookupField inside'+selectedLookupField);
	     }
	     console.log('component.find("selected_object")'+component.find("selected_object"));
	     var sObjectSelected  = component.find("selected_object").get("v.value");
	      if(selectedLookupField == '--None--' || sObjectSelected == '--None--' || selectedLookupField == '')
			 return;
		 allFeildSelected.setParams({ "ObjectName" : component.find("selected_object").get("v.value"),
		  "LookupObjectName" : selectedLookupField,
		   "LookupId" : component.find("lookupObjectId").get("v.value"), 
		 "sobjectFieldListSelected" : component.find("searchFields").get("v.value")});
		 console.log('********************');
		
		 console.log('selectedLookupField :'+selectedLookupField.length);
		 
		 console.log(component.find("selected_object").get("v.value"));
		 console.log(selectedLookupField );
		 console.log(component.find("lookupObjectId").get("v.value"));
		 console.log(component.find("searchFields").get("v.value"));
		 allFeildSelected.fire();
		 console.log('fired an event');
	}
	
})