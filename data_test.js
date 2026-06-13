window.__WORKSPACE_DATA__ = {
                contextPath: "${pageContext.request.contextPath}",
                assessmentBaseUrl: "${assessmentWorkspaceBaseUrl}",
                course: {
                    courseId: `${selectedCourse.courseId}`,
                    courseName: `<c:out value='${selectedCourse.courseName}' escapeXml='true'/>`,
                    status: `<c:out value='${selectedCourse.status}'/>`,
                    category: `<c:out value='${selectedCourse.category}'/>`,
                    level: `<c:out value='${selectedCourse.level}'/>`,
                    displayDuration: `<c:out value='${selectedCourse.displayDuration}'/>`,
                    description: `<c:out value='${selectedCourse.description}' escapeXml='true'/>`
                },
                stats: {
                    totalStudents: ${totalStudents != null ? totalStudents : 0},
                    publishedMaterials: ${publishedMaterials != null ? publishedMaterials : 0},
                    assessmentCount: ${assessmentCount != null ? assessmentCount : 0},
                    pendingGrading: ${pendingGrading != null ? pendingGrading : 0}
                },
                materials: [
                    <c:forEach var="mat" items="${materials}" varStatus="status">
                    {
                        materialId: `${mat.materialId}`,
                        title: `<c:out value='${mat.title}' escapeXml='true'/>`,
                        type: `<c:out value='${mat.materialType}'/>`,
                        description: `<c:out value='${mat.description}' escapeXml='true'/>`,
                        order: `${mat.displayOrder}`,
                        filePath: `<c:out value='${mat.filePath}'/>`
                    }${not status.last ? ',' : ''}
                    </c:forEach>
                ],
                assessments: [
                    <c:forEach var="ass" items="${assessments}" varStatus="status">
                    {
                        id: `${ass.assessmentId}`,
                        title: `<c:out value='${ass.title}' escapeXml='true'/>`,
                        type: `<c:out value='${ass.type}'/>`,
                        instructions: `<c:out value='${ass.instructions}' escapeXml='true'/>`,
                        attempts: ${submissionCountByAssessmentId[ass.assessmentId] != null ? submissionCountByAssessmentId[ass.assessmentId] : 0},
                        duration: `${ass.duration}`,
                        points: `${ass.totalMarks}`
                    }${not status.last ? ',' : ''}
                    </c:forEach>
                ],
                enrollments: [
                    <c:forEach var="enr" items="${enrollments}" varStatus="status">
                    {
                        id: `${enr.enrollmentId}`,
                        name: `<c:out value='${enr.studentName}' escapeXml='true'/>`,
                        email: `<c:out value='${enr.studentEmail}' escapeXml='true'/>`,
                        status: `<c:out value='${enr.status}'/>`,
                        progress: ${not empty enr.progress ? enr.progress : 0},
                        date: `<c:out value='${enr.enrollmentDate}'/>`
                    }${not status.last ? ',' : ''}
                    </c:forEach>
                ]
            };