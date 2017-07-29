({
	handleFieldSelectedValueAddedEvent : function(component, event, helper) {
	helper.handleFieldSelectedValueAddedEventHelper(component, event, helper);	
	},
	
	assignReverseLookup : function(cmp, event, helper)
	{
		helper.assignReverseLookupHelper(cmp, event, helper);
	},
	
	findSobjects : function(cmp, event, helper)
	{
		helper.findSobjectsHelper(cmp, event, helper);
	},
	next : function(component, event, helper) {
		var prevVar = false;
        var nextVar = true;
        helper.paginationaHelper(component, prevVar, nextVar)                           
    },
         
    prev : function(component, event, helper) {
        var prevVar = true;
        var nextVar = false;
        helper.paginationaHelper(component, prevVar, nextVar)                 
    },
})