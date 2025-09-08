<%-- 
    Document   : CorpusStatistics
    Created on : 09.09.2024, 15:09:55
    Author     : bernd
--%>

<%@page import="java.util.Locale"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="org.zumult.objects.CorpusStatistics"%>
<%@page import="org.zumult.objects.Corpus"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page import="org.zumult.io.IOHelper"%>
<%@page import="org.exmaralda.partitureditor.jexmaralda.convert.StylesheetFactory"%>
<%@page import="org.zumult.backend.Configuration"%>
<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@include file="../WEB-INF/jspf/locale.jspf" %>     

<%
        String corpusID = request.getParameter("corpusID");

        String pageName = "ZuMult";
        String pageTitle = "Corpus statistics";
        //String imgSrc = "../images/eslo_bandeau.jpg";

        BackendInterface backendInterface = BackendInterfaceFactory.newBackendInterface();
        Corpus corpus = backendInterface.getCorpus(corpusID);
        CorpusStatistics stats = corpus.getCorpusStatistics();
        String statsXML = stats.toXML();
        // where default = "/org/zumult/io/statistics2HTML.xsl"
        String xsl = Configuration.getStatistics2HTMLStylesheet();

        
        String[][] param = {
            {"x", "y"}
        };
        String html = new IOHelper().applyInternalStylesheetToString(xsl, statsXML, param);
    
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">        
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <link rel="stylesheet" href="css/query.css">
        
        <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>                
        <script src="js/tgdp.js"></script>
        <title>Corpus Statistics : <%= corpusID %> </title>
        <link rel="stylesheet" href="../css/overview.css"/>       
        <style type="text/css">
        </style>
        
        <!-- <link rel="stylesheet" href="css/overview.css"/> -->
        
    </head>
    <body>
        <%@include file="../WEB-INF/jspf/zumultNav.jspf" %>                                                
        
        
        <div class="row">
            <div class="col-sm-1">
            </div>
            <div class="col-sm-10">
                <h3>Corpus statistics for <%= corpusID %> </h3>
                <%= html %>
            </div>
            <div class="col-sm-1">
            </div>
        </div>
        <%@include file="../WEB-INF/jspf/metadataModal.jspf" %>        
    </body>
</html>
