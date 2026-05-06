package com.psm.elearning.model;

import jakarta.validation.constraints.*;

/**
 * AssessmentQuestion entity representing questions in an assessment.
 * Matches the AssessmentQuestion table schema.
 * 
 * Uses Lombok for automatic getter/setter generation.
 * Uses Jakarta Bean Validation for input validation.
 */
public class AssessmentQuestion {
    @NotNull(message = "Question ID cannot be null")
    private Integer questionId;
    
    @NotNull(message = "Assessment ID is required")
    private Integer assessmentId;
    
    @NotBlank(message = "Question text is required")
    @Size(max = 5000, message = "Question text must not exceed 5000 characters")
    private String questionText;
    
    @Size(max = 500, message = "Option A must not exceed 500 characters")
    private String optionA;
    
    @Size(max = 500, message = "Option B must not exceed 500 characters")
    private String optionB;
    
    @Size(max = 500, message = "Option C must not exceed 500 characters")
    private String optionC;
    
    @Size(max = 500, message = "Option D must not exceed 500 characters")
    private String optionD;
    
    @Pattern(regexp = "^[A-D]$", message = "Correct option must be A, B, C, or D")
    private String correctOption;

    @Size(max = 500, message = "Attachment URL must not exceed 500 characters")
    private String attachmentUrl;

    @Size(max = 255, message = "Attachment name must not exceed 255 characters")
    private String attachmentName;
    
    @DecimalMin(value = "0.0", message = "Marks must be >= 0")
    @DecimalMax(value = "100.0", message = "Marks must not exceed 100")
    private Double marks;
    
    // Constructors
    public AssessmentQuestion() {}
    
    public AssessmentQuestion(Integer questionId, Integer assessmentId, String questionText,
                             String optionA, String optionB, String optionC, String optionD,
                             String correctOption, Double marks) {
        this.questionId = questionId;
        this.assessmentId = assessmentId;
        this.questionText = questionText;
        this.optionA = optionA;
        this.optionB = optionB;
        this.optionC = optionC;
        this.optionD = optionD;
        this.correctOption = correctOption;
        this.marks = marks;
    }

    public AssessmentQuestion(Integer questionId, Integer assessmentId, String questionText,
                              String optionA, String optionB, String optionC, String optionD,
                              String correctOption, Double marks, String attachmentUrl, String attachmentName) {
        this(questionId, assessmentId, questionText, optionA, optionB, optionC, optionD, correctOption, marks);
        this.attachmentUrl = attachmentUrl;
        this.attachmentName = attachmentName;
    }
    
    // Getters and Setters
    public Integer getQuestionId() { return questionId; }
    public void setQuestionId(Integer questionId) { this.questionId = questionId; }
    
    public Integer getAssessmentId() { return assessmentId; }
    public void setAssessmentId(Integer assessmentId) { this.assessmentId = assessmentId; }
    
    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }
    
    public String getOptionA() { return optionA; }
    public void setOptionA(String optionA) { this.optionA = optionA; }
    
    public String getOptionB() { return optionB; }
    public void setOptionB(String optionB) { this.optionB = optionB; }
    
    public String getOptionC() { return optionC; }
    public void setOptionC(String optionC) { this.optionC = optionC; }
    
    public String getOptionD() { return optionD; }
    public void setOptionD(String optionD) { this.optionD = optionD; }
    
    public String getCorrectOption() { return correctOption; }
    public void setCorrectOption(String correctOption) { this.correctOption = correctOption; }

    public String getAttachmentUrl() { return attachmentUrl; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }

    public String getAttachmentName() { return attachmentName; }
    public void setAttachmentName(String attachmentName) { this.attachmentName = attachmentName; }
    
    public Double getMarks() { return marks; }
    public void setMarks(Double marks) { this.marks = marks; }
}






