<%
    String target = request.getContextPath() + "/admin/payment";
    String queryString = request.getQueryString();
    if (queryString != null && !queryString.isEmpty()) {
        target += "?" + queryString;
    }
    response.sendRedirect(target);
%>
