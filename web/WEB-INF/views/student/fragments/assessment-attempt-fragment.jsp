<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<section class="ax-stage" data-attempt-shell>
    <article class="ax-frame ax-focus__hero">
        <div>
            <span class="ax-overview__eyebrow"><i class="fas fa-shield-halved"></i> Active Assessment</span>
            <h1 class="ax-focus__title">${assessment.title}</h1>
            <p class="ax-focus__body">Move through the questions using the stepper, keep an eye on the timer, and submit when you are ready.</p>
        </div>
        <div class="ax-timer" data-timer>
            <i class="fas fa-clock"></i>
            <span data-timer-text>00:00</span>
        </div>
    </article>

    <div class="ax-layout">
        <section class="ax-panel">
            <div class="ax-progress">
                <div class="ax-progress__meta">
                    <span>Question <strong data-current-question>1</strong> of ${questions.size()}</span>
                    <span>Completion progress</span>
                </div>
                <div class="ax-progress__bar">
                    <div class="ax-progress__fill" data-progress-fill></div>
                </div>
            </div>

            <div class="ax-stepper" style="margin-top: 20px;">
                <c:forEach var="q" items="${questions}" varStatus="loop">
                    <button type="button" class="ax-stepper__item ${loop.first ? 'is-active' : ''}" data-step-index="${loop.index}">${loop.index + 1}</button>
                </c:forEach>
            </div>

            <form method="post"
                  action="${pageContext.request.contextPath}/student/assessments"
                  data-attempt-form
                  data-timer-start="${timerStartTime}"
                  data-timer-duration="${timerDurationSeconds}"
                  style="display: grid; gap: 24px; margin-top: 24px;">
                <input type="hidden" name="assessmentId" value="${assessment.assessmentId}">
                <input type="hidden" name="enrollmentId" value="${enrollment.enrollmentId}">
                <input type="hidden" name="timerStart" value="${timerStartTime}">
                <input type="hidden" name="timerDuration" value="${timerDurationSeconds}">
                <input type="hidden" name="exitSubmission" value="0">

                <c:forEach var="q" items="${questions}" varStatus="loop">
                    <article class="ax-question ${loop.first ? 'is-active' : ''}" data-question-index="${loop.index}">
                        <div class="ax-question__head">
                            <div class="ax-question__index">${loop.index + 1}</div>
                            <h2 class="ax-question__title">${q.questionText}</h2>
                        </div>
                        <div class="ax-answer-grid">
                            <label class="ax-answer-card">
                                <input type="radio" name="q_${q.questionId}" value="A" required>
                                <span class="ax-answer-card__bullet"></span>
                                <span class="ax-answer-card__label">A</span>
                                <span class="ax-answer-card__text">${q.optionA}</span>
                            </label>
                            <label class="ax-answer-card">
                                <input type="radio" name="q_${q.questionId}" value="B" required>
                                <span class="ax-answer-card__bullet"></span>
                                <span class="ax-answer-card__label">B</span>
                                <span class="ax-answer-card__text">${q.optionB}</span>
                            </label>
                            <label class="ax-answer-card">
                                <input type="radio" name="q_${q.questionId}" value="C" required>
                                <span class="ax-answer-card__bullet"></span>
                                <span class="ax-answer-card__label">C</span>
                                <span class="ax-answer-card__text">${q.optionC}</span>
                            </label>
                            <label class="ax-answer-card">
                                <input type="radio" name="q_${q.questionId}" value="D" required>
                                <span class="ax-answer-card__bullet"></span>
                                <span class="ax-answer-card__label">D</span>
                                <span class="ax-answer-card__text">${q.optionD}</span>
                            </label>
                        </div>
                    </article>
                </c:forEach>

                <div class="ax-sticky-bar">
                    <div class="ax-sticky-bar__summary">
                        <strong style="color: var(--ax-heading);">Submit when your answers are ready</strong>
                        <span style="color: var(--ax-muted);">The button locks and switches to a grading state immediately.</span>
                    </div>
                    <div class="ax-actions">
                        <button type="button" class="ax-btn ax-btn--secondary" data-prev-question>
                            <i class="fas fa-arrow-left"></i>
                            <span>Previous</span>
                        </button>
                        <button type="button" class="ax-btn ax-btn--secondary" data-next-question>
                            <span>Next</span>
                            <i class="fas fa-arrow-right"></i>
                        </button>
                        <button type="button" class="ax-btn ax-btn--danger" data-exit-attempt>
                            <i class="fas fa-door-open"></i>
                            <span>Save & Exit</span>
                        </button>
                        <button type="submit" class="ax-btn ax-btn--primary" data-submit-button>
                            <i class="fas fa-paper-plane"></i>
                            <span>Submit Assessment</span>
                        </button>
                    </div>
                </div>
            </form>
        </section>

        <aside class="ax-side-panel">
            <h2 class="ax-side-panel__title">Assessment Snapshot</h2>
            <p class="ax-side-panel__copy">Keep an eye on timing, completion, and attempt context while you work.</p>
            <div class="ax-review-list" style="margin-top: 20px;">
                <div class="ax-inline-card">
                    <i class="fas fa-clock"></i>
                    <div><span>Time Limit</span><strong>${assessment.duration != null ? assessment.duration : '--'}${assessment.duration != null ? ' min' : ''}</strong></div>
                </div>
                <div class="ax-inline-card">
                    <i class="fas fa-list-check"></i>
                    <div><span>Questions</span><strong>${questions.size()}</strong></div>
                </div>
                <div class="ax-inline-card">
                    <i class="fas fa-repeat"></i>
                    <div><span>Attempt</span><strong>${usedAttempts + 1} of ${allowedAttempts}</strong></div>
                </div>
                <div class="ax-inline-card">
                    <i class="fas fa-bullseye"></i>
                    <div><span>Passing Score</span><strong>70%</strong></div>
                </div>
            </div>
        </aside>
    </div>
</section>
