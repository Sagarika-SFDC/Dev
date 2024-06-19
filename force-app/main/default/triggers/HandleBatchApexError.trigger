trigger HandleBatchApexError on BatchApexErrorEvent (after insert) {
    
    if(trigger.isAfter && trigger.isInsert){
        HandleBatchApexErrorHelper.afterInsert(trigger.new);
    }

}