/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package org.zumult.web;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.zumult.backend.BackendInterface;
import org.zumult.objects.Corpus;
import org.zumult.objects.MetadataKey;

/**
 *
 * @author bernd
 */
public class ZuMultWebHelper {
    
    
    public static List<String> getSelectionSet(
            BackendInterface backendInterface,
            Corpus corpus,
            Set<MetadataKey> metadataKeys,
            String prefix, 
            String selectionKeyID) {
        List<String> selectionSet = new ArrayList<>();
        for (MetadataKey mk : metadataKeys){
            selectionSet.add(mk.getName("en"));
        }

        // this is new for #270, 07-03-2026
        // I am going out of may way here to make this robust
        // I will hopefully be given an award for this
        // the FIFA Peace Prize will do for now
        MetadataKey selectionKey = backendInterface.findMetadataKeyByID(selectionKeyID);
        if (selectionKey!=null){
            String allMetadataNames = corpus.getMetadataValue(selectionKey);
            if (allMetadataNames!=null && allMetadataNames.length()>0){
                List<String> configuredSelectionSet = new ArrayList<>();
                String[] tokenizedMetadataNames = allMetadataNames.split(";");
                for (String mn : tokenizedMetadataNames){
                    MetadataKey mk = backendInterface.findMetadataKeyByID(prefix + mn);
                    if (mk!=null){
                        configuredSelectionSet.add(mk.getName("en"));
                    }
                }
                if (!(configuredSelectionSet.isEmpty())){
                    selectionSet = configuredSelectionSet;
                }
            }
        }
        
        return selectionSet;
        
    }
    
}
