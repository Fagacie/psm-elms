<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<section class="container" data-attempt-shell>
    <div class="active_assessment_container">
        
        <div class="active_question_header">
            <div>
                <span style="font-size: 0.875rem; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;"><i class="fas fa-shield-halved"></i> Active Assessment</span>
                <h1 class="title" style="margin-top: 4px; font-size: 1.75rem; text-align: left;">${assessment.title}</h1>
            </div>
            <div class="timer_box" data-timer>
                <i class="fas fa-clock"></i>
                <span data-timer-text>00:00</span>
            </div>
        </div>

        <div class="progress_row">
            <span class="progress_text">Question <strong data-current-question>1</strong> of ${questions.size()}</span>
            <span class="progress_text">Progress</span>
        </div>
        <div class="progress_bar_bg">
            <div class="progress_bar_fill" data-progress-fill></div>
        </div>

        <div class="stepper_row">
            <c:forEach var="q" items="${questions}" varStatus="loop">
                <button type="button" class="stepper_item ${loop.first ? 'stepper_item_active' : ''}" data-step-index="${loop.index}">${loop.index + 1}</button>
            </c:forEach>
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/student/assessments"
              data-attempt-form
              data-timer-start="${timerStartTime}"
              data-timer-duration="${timerDurationSeconds}"
              class="ax-attempt-form">
            <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
            <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
            <input type="hidden" name="timerStart" value="${timerStartTime}">
            <input type="hidden" name="timerDuration" value="${timerDurationSeconds}">
            <input type="hidden" name="exitSubmission" value="0">

            <c:forEach var="q" items="${questions}" varStatus="loop">
                <article class="ax-question ${loop.first ? 'is-active' : ''}" data-question-index="${loop.index}" style="display: ${loop.first ? 'block' : 'none'};">
                    <h2 class="question_statement">${loop.index + 1}. ${q.questionText}</h2>
                    
                    <div class="choices_container">
                        <label class="choice_block">
                            <input type="radio" name="q_${q.questionId}" value="A" style="display: none;" required>
                            <span class="choice_badge">A</span>
                            <span class="choice_text">${q.optionA}</span>
                        </label>
                        <label class="choice_block">
                            <input type="radio" name="q_${q.questionId}" value="B" style="display: none;" required>
                            <span class="choice_badge">B</span>
                            <span class="choice_text">${q.optionB}</span>
                        </label>
                        <label class="choice_block">
                            <input type="radio" name="q_${q.questionId}" value="C" style="display: none;" required>
                            <span class="choice_badge">C</span>
                            <span class="choice_text">${q.optionC}</span>
                        </label>
                        <label class="choice_block">
                            <input type="radio" name="q_${q.questionId}" value="D" style="display: none;" required>
                            <span class="choice_badge">D</span>
                            <span class="choice_text">${q.optionD}</span>
                        </label>
                    </div>
                </article>
            </c:forEach>

            <div class="submit_action_container" style="justify-content: space-between; border-top: 1px solid #e2e8f0; padding-top: 24px;">
                <div style="display: flex; gap: 8px;">
                    <button type="button" class="secondary_button" data-prev-question>
                        <i class="fas fa-arrow-left"></i>
                        <span>Previous</span>
                    </button>
                    <button type="button" class="secondary_button" data-next-question>
                        <span>Next</span>
                        <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
                <div style="display: flex; gap: 8px;">
                    <button type="button" class="danger_button" data-exit-attempt>
                        <i class="fas fa-door-open"></i>
                        <span>Save & Exit</span>
                    </button>
                    <button type="submit" class="primary_button" data-submit-button>
                        <i class="fas fa-paper-plane"></i>
                        <span>Submit Assessment</span>
                    </button>
                </div>
            </div>
        </form>
    </div>
</section>
