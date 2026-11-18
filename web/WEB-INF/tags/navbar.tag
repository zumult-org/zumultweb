<%@ tag pageEncoding="UTF-8" body-content="empty" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<%@ attribute name="applicationName" required="true" %>
<%@ attribute name="objectTitle" required="false" %>

<%@ attribute name="institutionLogo" required="false" %>
<%@ attribute name="institutionName" required="false" %>
<%@ attribute name="institutionURL" required="false" %>

<%@ attribute name="menus" fragment="true" required="false" %>

<%@ attribute name="search" fragment="true" required="false" %>

<%@ attribute name="highlighting" fragment="true" required="false" %>

<%@ attribute name="language" required="true" %>
<%@ attribute name="helpURL" required="false" %>
<%@ attribute name="helpLabel" required="false" %>

<nav class="navbar navbar-expand-lg zumult-navbar" data-bs-theme="dark">

    <div class="container-fluid">
        <!-- BRANDING AREA -->
        <div class="d-flex align-items-center gap-3">

            <!-- ZuMult logo -->
            <a href="https://zumult.org">
                <img class="zumult-nav-logo"
                     title="zumult.org"
                     src="${pageContext.request.contextPath}/images/cropped-ZuMult.png"
                     alt="ZuMult"/>
            </a>

            <!-- Optional institutional logo -->
            <c:if test="${not empty institutionLogo}">
                <a href="${institutionURL}">
                    <img class="zumult-nav-logo"
                         src="${institutionLogo}"
                         alt="${institutionName}"/>
                </a>
            </c:if>

            <!-- Application and object title -->
            <div class="zumult-nav-title">

                <div class="zumult-nav-application">
                    <strong>ZuMult</strong>
                    <span class="zumult-nav-separator">|</span>
                    <span>${applicationName}</span>
                </div>

                <c:if test="${not empty objectTitle}">
                    <div class="zumult-nav-object" id="nav-object-title">
                        <c:out value="${objectTitle}"/>
                    </div>
                </c:if>

            </div>
        </div> <!-- end branding area -->
        
        <!-- APP SEPCIFIC MENU -->
        <c:if test="${not empty menus}">
            <ul class="navbar-nav me-auto ms-4">
                <jsp:invoke fragment="menus"/>
            </ul>
        </c:if>         
        
        <!-- SEARCH FIELD -->
        <c:if test="${not empty search}">
            <div class="zumult-nav-search ms-auto me-3">
                <jsp:invoke fragment="search"/>
            </div>
        </c:if>     
        
        <c:if test="${not empty highlighting}">
            <div class="d-flex align-items-center gap-1 me-3">
                <jsp:invoke fragment="highlighting"/>
            </div>
        </c:if>        
        
        <div class="d-flex align-items-center gap-3 ms-auto">

            <!-- LANGUAGE SWITCHER -->
            <select id="selectLang"
                    class="form-select form-select-sm w-auto"
                    data-bs-theme="light"                    
                    aria-label="Language">

                <option value="de"
                    ${language eq 'de' ? 'selected' : ''}>
                    Deutsch
                </option>

                <option value="en"
                    ${language eq 'en' ? 'selected' : ''}>
                    English
                </option>

            </select>

            <!-- HELP -->
            <c:if test="${not empty helpURL}">
                <a class="nav-link text-nowrap"
                   href="${helpURL}"
                   target="_blank"
                   rel="noopener">
                    <i class="fas fa-question-circle"></i>
                    <c:out value="${empty helpLabel ? 'Help' : helpLabel}"/>
                </a>
            </c:if>

        </div>        
        
    </div> 
                

</nav>