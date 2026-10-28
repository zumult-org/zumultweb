/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 * 
 * 
 * Document   : xslTransformation
 * Created on : 27.10.2026, 10:07:25
 * Author     : Elena_Frick
 */

async function transformXmlToHtml(xml, pathToStylesheet, parameters) {

    // Execute the XSLT transformation using SaxonJS
    const result = await SaxonJS.transform({
        stylesheetLocation: pathToStylesheet,
        sourceText: xml,
        stylesheetParams: parameters || {},
        destination: "serialized" // "serialized" requests the transformation result as a string
    }, "async");

    // Return the generated HTML as a string.
    return result.principalResult;
}
