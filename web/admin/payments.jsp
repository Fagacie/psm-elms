<%
    String target = request.getContextPath() + "/admin/payments";
    String queryString = request.getQueryString();
    if (queryString != null && !queryString.isEmpty()) {
        target += "?" + queryString;
    }
    response.sendRedirect(target);
%>
