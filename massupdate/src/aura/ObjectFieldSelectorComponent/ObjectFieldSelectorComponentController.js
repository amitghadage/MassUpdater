({
  doInit : function(component, event, helper) {
  helper.setSobjectList(component);
 },
 
 renderFieldNames : function(component, event, helper) {
	helper.getAllLookups(component);
},

 handleProceedClick : function(component, event, helper)
 {
	 helper.getRLookupObjectList(component, event);
 },
 
 handleLookupSelected : function(component)
 {
	 component.set("v.lookupFieldSelected", component.find("selected_Lookup_Field").get("v.value"));
 },
})