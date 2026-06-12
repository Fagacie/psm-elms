<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Register - PSM E-Learning</title>
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                rel="stylesheet">
            <!-- Include Profile CSS modules styles for identical layout & colors -->
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/Register.module.css">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        </head>

        <body class="sv-page">
            <div class="reg_viewport">

                <div class="reg_card">
                    <div style="text-align: center; margin-bottom: 32px;">
                        <h1>
                            Create Account</h1>
                        <p class="reg_sub">Set up
                            your account and begin learning today.</p>
                    </div>

                    <!-- Error Banner -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-error"
                            style="border-radius: 8px; margin-bottom: 24px; display: flex; align-items: center; background: rgba(239, 68, 68, 0.08); border: 1px solid rgba(239, 68, 68, 0.2); color: #b91c1c; padding: 12px 16px; font-size: 0.9rem; width: 100%; box-sizing: border-box;">
                            <i class="fas fa-exclamation-circle" style="margin-right: 8px;"></i> ${error}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="post"
                        enctype="multipart/form-data" novalidate
                        style="display: flex; flex-direction: column; gap: 28px; margin: 0;">

                        <!-- Modern Avatar Picker -->
                        <div style="display: flex; flex-direction: column; align-items: center; gap: 12px; margin-bottom: 8px;">
                            <label for="passportPhoto" class="reg_avatar_picker" id="photoDropzone">
                                <input id="passportPhoto" name="passportPhoto" type="file" accept="image/jpeg,image/png,image/gif" class="reg_file_input">
                                <i data-lucide="camera" class="reg_camera_icon"></i>
                                <img id="photoPreviewImage" alt="Selected profile photo preview" class="reg_avatarImg" style="display: none;">
                            </label>
                            <span class="reg_label" style="text-align: center;">Upload Passport Photo</span>
                        </div>

                        <!-- Section 1: Account Credentials -->
                        <div style="display: flex; flex-direction: column; gap: 16px;">
                            <h4>
                                Account Credentials</h4>
                            <div class="reg_formGrid">
                                <div class="reg_field reg_fullWidth">
                                    <label class="reg_label" for="email">Email Address  <span class="reg_req">(Required)</span></label>
                                    <input id="email" name="email" type="email" value="${param.email}" required
                                        class="reg_input" placeholder="e.g. user@example.com">
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="password">Password  <span class="reg_req">(Required)</span></label>
                                    <input id="password" name="password" type="password" required class="reg_input"
                                        placeholder="Min. 8 characters">
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="confirmPassword">Confirm Password  <span class="reg_req">(Required)</span></label>
                                    <input id="confirmPassword" name="confirmPassword" type="password" required
                                        class="reg_input" placeholder="Repeat password">
                                </div>
                            </div>
                        </div>

                        <!-- Section 2: Personal Information -->
                        <div style="display: flex; flex-direction: column; gap: 16px;">
                            <h4>
                                Personal Information</h4>
                            <div class="reg_formGrid">
                                <div class="reg_field">
                                    <label class="reg_label" for="fullName">Full Name  <span class="reg_req">(Required)</span></label>
                                    <input id="fullName" name="fullName" type="text" value="${param.fullName}" required
                                        class="reg_input" placeholder="Enter your full name">
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="phone">Phone Number  <span class="reg_req">(Required)</span></label>
                                    <input id="phone" name="phone" type="tel" value="${param.phone}" required
                                        class="reg_input" placeholder="e.g. +255712345678">
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="dob">Date of Birth  <span class="reg_opt">(Optional)</span></label>
                                    <input id="dob" name="dob" type="date" value="${param.dob}" class="reg_input">
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="gender">Gender  <span class="reg_opt">(Optional)</span></label>
                                    <select id="gender" name="gender" class="reg_select">
                                        <option value="">Select Gender</option>
                                        <option value="Male" ${param.gender=='Male' ? 'selected' : '' }>Male</option>
                                        <option value="Female" ${param.gender=='Female' ? 'selected' : '' }>Female
                                        </option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Section 3: Location & Additional Details -->
                        <div style="display: flex; flex-direction: column; gap: 16px;">
                            <h4>
                                Location & Additional Details</h4>
                            <div class="reg_formGrid">
                                <div class="reg_field">
                                    <label class="reg_label" for="country">Country  <span class="reg_req">(Required)</span></label>
                                    <select id="country" name="country" required class="reg_select">
                                        <option value="">Select Your Country</option>
                                        <option value="Afghanistan" ${param.country=='Afghanistan' ? 'selected' : '' }>
                                            Afghanistan (+93)</option>
                                        <option value="Albania" ${param.country=='Albania' ? 'selected' : '' }>Albania
                                            (+355)</option>
                                        <option value="Algeria" ${param.country=='Algeria' ? 'selected' : '' }>Algeria
                                            (+213)</option>
                                        <option value="Andorra" ${param.country=='Andorra' ? 'selected' : '' }>Andorra
                                            (+376)</option>
                                        <option value="Angola" ${param.country=='Angola' ? 'selected' : '' }>Angola
                                            (+244)</option>
                                        <option value="Argentina" ${param.country=='Argentina' ? 'selected' : '' }>
                                            Argentina (+54)</option>
                                        <option value="Armenia" ${param.country=='Armenia' ? 'selected' : '' }>Armenia
                                            (+374)</option>
                                        <option value="Australia" ${param.country=='Australia' ? 'selected' : '' }>
                                            Australia (+61)</option>
                                        <option value="Austria" ${param.country=='Austria' ? 'selected' : '' }>Austria
                                            (+43)</option>
                                        <option value="Azerbaijan" ${param.country=='Azerbaijan' ? 'selected' : '' }>
                                            Azerbaijan (+994)</option>
                                        <option value="Bahamas" ${param.country=='Bahamas' ? 'selected' : '' }>Bahamas
                                            (+1-242)</option>
                                        <option value="Bahrain" ${param.country=='Bahrain' ? 'selected' : '' }>Bahrain
                                            (+973)</option>
                                        <option value="Bangladesh" ${param.country=='Bangladesh' ? 'selected' : '' }>
                                            Bangladesh (+880)</option>
                                        <option value="Barbados" ${param.country=='Barbados' ? 'selected' : '' }>
                                            Barbados (+1-246)</option>
                                        <option value="Belarus" ${param.country=='Belarus' ? 'selected' : '' }>Belarus
                                            (+375)</option>
                                        <option value="Belgium" ${param.country=='Belgium' ? 'selected' : '' }>Belgium
                                            (+32)</option>
                                        <option value="Belize" ${param.country=='Belize' ? 'selected' : '' }>Belize
                                            (+501)</option>
                                        <option value="Benin" ${param.country=='Benin' ? 'selected' : '' }>Benin (+229)
                                        </option>
                                        <option value="Bhutan" ${param.country=='Bhutan' ? 'selected' : '' }>Bhutan
                                            (+975)</option>
                                        <option value="Bolivia" ${param.country=='Bolivia' ? 'selected' : '' }>Bolivia
                                            (+591)</option>
                                        <option value="Bosnia and Herzegovina" ${param.country=='Bosnia and Herzegovina'
                                            ? 'selected' : '' }>Bosnia and Herzegovina (+387)</option>
                                        <option value="Botswana" ${param.country=='Botswana' ? 'selected' : '' }>
                                            Botswana (+267)</option>
                                        <option value="Brazil" ${param.country=='Brazil' ? 'selected' : '' }>Brazil
                                            (+55)</option>
                                        <option value="Brunei" ${param.country=='Brunei' ? 'selected' : '' }>Brunei
                                            (+673)</option>
                                        <option value="Bulgaria" ${param.country=='Bulgaria' ? 'selected' : '' }>
                                            Bulgaria (+359)</option>
                                        <option value="Burkina Faso" ${param.country=='Burkina Faso' ? 'selected' : ''
                                            }>Burkina Faso (+226)</option>
                                        <option value="Burundi" ${param.country=='Burundi' ? 'selected' : '' }>Burundi
                                            (+257)</option>
                                        <option value="Cambodia" ${param.country=='Cambodia' ? 'selected' : '' }>
                                            Cambodia (+855)</option>
                                        <option value="Cameroon" ${param.country=='Cameroon' ? 'selected' : '' }>
                                            Cameroon (+237)</option>
                                        <option value="Canada" ${param.country=='Canada' ? 'selected' : '' }>Canada (+1)
                                        </option>
                                        <option value="Cape Verde" ${param.country=='Cape Verde' ? 'selected' : '' }>
                                            Cape Verde (+238)</option>
                                        <option value="Central African Republic"
                                            ${param.country=='Central African Republic' ? 'selected' : '' }>Central
                                            African Republic (+236)</option>
                                        <option value="Chad" ${param.country=='Chad' ? 'selected' : '' }>Chad (+235)
                                        </option>
                                        <option value="Chile" ${param.country=='Chile' ? 'selected' : '' }>Chile (+56)
                                        </option>
                                        <option value="China" ${param.country=='China' ? 'selected' : '' }>China (+86)
                                        </option>
                                        <option value="Colombia" ${param.country=='Colombia' ? 'selected' : '' }>
                                            Colombia (+57)</option>
                                        <option value="Comoros" ${param.country=='Comoros' ? 'selected' : '' }>Comoros
                                            (+269)</option>
                                        <option value="Congo" ${param.country=='Congo' ? 'selected' : '' }>Congo (+242)
                                        </option>
                                        <option value="Costa Rica" ${param.country=='Costa Rica' ? 'selected' : '' }>
                                            Costa Rica (+506)</option>
                                        <option value="Croatia" ${param.country=='Croatia' ? 'selected' : '' }>Croatia
                                            (+385)</option>
                                        <option value="Cuba" ${param.country=='Cuba' ? 'selected' : '' }>Cuba (+53)
                                        </option>
                                        <option value="Cyprus" ${param.country=='Cyprus' ? 'selected' : '' }>Cyprus
                                            (+357)</option>
                                        <option value="Czech Republic" ${param.country=='Czech Republic' ? 'selected'
                                            : '' }>Czech Republic (+420)</option>
                                        <option value="Denmark" ${param.country=='Denmark' ? 'selected' : '' }>Denmark
                                            (+45)</option>
                                        <option value="Djibouti" ${param.country=='Djibouti' ? 'selected' : '' }>
                                            Djibouti (+253)</option>
                                        <option value="Dominica" ${param.country=='Dominica' ? 'selected' : '' }>
                                            Dominica (+1-767)</option>
                                        <option value="Dominican Republic" ${param.country=='Dominican Republic'
                                            ? 'selected' : '' }>Dominican Republic (+1-809)</option>
                                        <option value="Ecuador" ${param.country=='Ecuador' ? 'selected' : '' }>Ecuador
                                            (+593)</option>
                                        <option value="Egypt" ${param.country=='Egypt' ? 'selected' : '' }>Egypt (+20)
                                        </option>
                                        <option value="El Salvador" ${param.country=='El Salvador' ? 'selected' : '' }>
                                            El Salvador (+503)</option>
                                        <option value="Equatorial Guinea" ${param.country=='Equatorial Guinea'
                                            ? 'selected' : '' }>Equatorial Guinea (+240)</option>
                                        <option value="Eritrea" ${param.country=='Eritrea' ? 'selected' : '' }>Eritrea
                                            (+291)</option>
                                        <option value="Estonia" ${param.country=='Estonia' ? 'selected' : '' }>Estonia
                                            (+372)</option>
                                        <option value="Ethiopia" ${param.country=='Ethiopia' ? 'selected' : '' }>
                                            Ethiopia (+251)</option>
                                        <option value="Fiji" ${param.country=='Fiji' ? 'selected' : '' }>Fiji (+679)
                                        </option>
                                        <option value="Finland" ${param.country=='Finland' ? 'selected' : '' }>Finland
                                            (+358)</option>
                                        <option value="France" ${param.country=='France' ? 'selected' : '' }>France
                                            (+33)</option>
                                        <option value="Gabon" ${param.country=='Gabon' ? 'selected' : '' }>Gabon (+241)
                                        </option>
                                        <option value="Gambia" ${param.country=='Gambia' ? 'selected' : '' }>Gambia
                                            (+220)</option>
                                        <option value="Georgia" ${param.country=='Georgia' ? 'selected' : '' }>Georgia
                                            (+995)</option>
                                        <option value="Germany" ${param.country=='Germany' ? 'selected' : '' }>Germany
                                            (+49)</option>
                                        <option value="Ghana" ${param.country=='Ghana' ? 'selected' : '' }>Ghana (+233)
                                        </option>
                                        <option value="Greece" ${param.country=='Greece' ? 'selected' : '' }>Greece
                                            (+30)</option>
                                        <option value="Grenada" ${param.country=='Grenada' ? 'selected' : '' }>Grenada
                                            (+1-473)</option>
                                        <option value="Guatemala" ${param.country=='Guatemala' ? 'selected' : '' }>
                                            Guatemala (+502)</option>
                                        <option value="Guinea" ${param.country=='Guinea' ? 'selected' : '' }>Guinea
                                            (+224)</option>
                                        <option value="Guinea-Bissau" ${param.country=='Guinea-Bissau' ? 'selected' : ''
                                            }>Guinea-Bissau (+245)</option>
                                        <option value="Guyana" ${param.country=='Guyana' ? 'selected' : '' }>Guyana
                                            (+592)</option>
                                        <option value="Haiti" ${param.country=='Haiti' ? 'selected' : '' }>Haiti (+509)
                                        </option>
                                        <option value="Honduras" ${param.country=='Honduras' ? 'selected' : '' }>
                                            Honduras (+504)</option>
                                        <option value="Hong Kong" ${param.country=='Hong Kong' ? 'selected' : '' }>Hong
                                            Kong (+852)</option>
                                        <option value="Hungary" ${param.country=='Hungary' ? 'selected' : '' }>Hungary
                                            (+36)</option>
                                        <option value="Iceland" ${param.country=='Iceland' ? 'selected' : '' }>Iceland
                                            (+354)</option>
                                        <option value="India" ${param.country=='India' ? 'selected' : '' }>India (+91)
                                        </option>
                                        <option value="Indonesia" ${param.country=='Indonesia' ? 'selected' : '' }>
                                            Indonesia (+62)</option>
                                        <option value="Iran" ${param.country=='Iran' ? 'selected' : '' }>Iran (+98)
                                        </option>
                                        <option value="Iraq" ${param.country=='Iraq' ? 'selected' : '' }>Iraq (+964)
                                        </option>
                                        <option value="Ireland" ${param.country=='Ireland' ? 'selected' : '' }>Ireland
                                            (+353)</option>
                                        <option value="Israel" ${param.country=='Israel' ? 'selected' : '' }>Israel
                                            (+972)</option>
                                        <option value="Italy" ${param.country=='Italy' ? 'selected' : '' }>Italy (+39)
                                        </option>
                                        <option value="Jamaica" ${param.country=='Jamaica' ? 'selected' : '' }>Jamaica
                                            (+1-876)</option>
                                        <option value="Japan" ${param.country=='Japan' ? 'selected' : '' }>Japan (+81)
                                        </option>
                                        <option value="Jordan" ${param.country=='Jordan' ? 'selected' : '' }>Jordan
                                            (+962)</option>
                                        <option value="Kazakhstan" ${param.country=='Kazakhstan' ? 'selected' : '' }>
                                            Kazakhstan (+7)</option>
                                        <option value="Kenya" ${param.country=='Kenya' ? 'selected' : '' }>Kenya (+254)
                                        </option>
                                        <option value="Kiribati" ${param.country=='Kiribati' ? 'selected' : '' }>
                                            Kiribati (+686)</option>
                                        <option value="Kuwait" ${param.country=='Kuwait' ? 'selected' : '' }>Kuwait
                                            (+965)</option>
                                        <option value="Kyrgyzstan" ${param.country=='Kyrgyzstan' ? 'selected' : '' }>
                                            Kyrgyzstan (+996)</option>
                                        <option value="Laos" ${param.country=='Laos' ? 'selected' : '' }>Laos (+856)
                                        </option>
                                        <option value="Latvia" ${param.country=='Latvia' ? 'selected' : '' }>Latvia
                                            (+371)</option>
                                        <option value="Lebanon" ${param.country=='Lebanon' ? 'selected' : '' }>Lebanon
                                            (+961)</option>
                                        <option value="Lesotho" ${param.country=='Lesotho' ? 'selected' : '' }>Lesotho
                                            (+266)</option>
                                        <option value="Liberia" ${param.country=='Liberia' ? 'selected' : '' }>Liberia
                                            (+231)</option>
                                        <option value="Libya" ${param.country=='Libya' ? 'selected' : '' }>Libya (+218)
                                        </option>
                                        <option value="Liechtenstein" ${param.country=='Liechtenstein' ? 'selected' : ''
                                            }>Liechtenstein (+423)</option>
                                        <option value="Lithuania" ${param.country=='Lithuania' ? 'selected' : '' }>
                                            Lithuania (+370)</option>
                                        <option value="Luxembourg" ${param.country=='Luxembourg' ? 'selected' : '' }>
                                            Luxembourg (+352)</option>
                                        <option value="Macao" ${param.country=='Macao' ? 'selected' : '' }>Macao (+853)
                                        </option>
                                        <option value="Macedonia" ${param.country=='Macedonia' ? 'selected' : '' }>
                                            Macedonia (+389)</option>
                                        <option value="Madagascar" ${param.country=='Madagascar' ? 'selected' : '' }>
                                            Madagascar (+261)</option>
                                        <option value="Malawi" ${param.country=='Malawi' ? 'selected' : '' }>Malawi
                                            (+265)</option>
                                        <option value="Malaysia" ${param.country=='Malaysia' ? 'selected' : '' }>
                                            Malaysia (+60)</option>
                                        <option value="Maldives" ${param.country=='Maldives' ? 'selected' : '' }>
                                            Maldives (+960)</option>
                                        <option value="Mali" ${param.country=='Mali' ? 'selected' : '' }>Mali (+223)
                                        </option>
                                        <option value="Malta" ${param.country=='Malta' ? 'selected' : '' }>Malta (+356)
                                        </option>
                                        <option value="Marshall Islands" ${param.country=='Marshall Islands'
                                            ? 'selected' : '' }>Marshall Islands (+692)</option>
                                        <option value="Mauritania" ${param.country=='Mauritania' ? 'selected' : '' }>
                                            Mauritania (+222)</option>
                                        <option value="Mauritius" ${param.country=='Mauritius' ? 'selected' : '' }>
                                            Mauritius (+230)</option>
                                        <option value="Mexico" ${param.country=='Mexico' ? 'selected' : '' }>Mexico
                                            (+52)</option>
                                        <option value="Micronesia" ${param.country=='Micronesia' ? 'selected' : '' }>
                                            Micronesia (+691)</option>
                                        <option value="Moldova" ${param.country=='Moldova' ? 'selected' : '' }>Moldova
                                            (+373)</option>
                                        <option value="Monaco" ${param.country=='Monaco' ? 'selected' : '' }>Monaco
                                            (+377)</option>
                                        <option value="Mongolia" ${param.country=='Mongolia' ? 'selected' : '' }>
                                            Mongolia (+976)</option>
                                        <option value="Montenegro" ${param.country=='Montenegro' ? 'selected' : '' }>
                                            Montenegro (+382)</option>
                                        <option value="Morocco" ${param.country=='Morocco' ? 'selected' : '' }>Morocco
                                            (+212)</option>
                                        <option value="Mozambique" ${param.country=='Mozambique' ? 'selected' : '' }>
                                            Mozambique (+258)</option>
                                        <option value="Myanmar" ${param.country=='Myanmar' ? 'selected' : '' }>Myanmar
                                            (+95)</option>
                                        <option value="Namibia" ${param.country=='Namibia' ? 'selected' : '' }>Namibia
                                            (+264)</option>
                                        <option value="Nauru" ${param.country=='Nauru' ? 'selected' : '' }>Nauru (+674)
                                        </option>
                                        <option value="Nepal" ${param.country=='Nepal' ? 'selected' : '' }>Nepal (+977)
                                        </option>
                                        <option value="Netherlands" ${param.country=='Netherlands' ? 'selected' : '' }>
                                            Netherlands (+31)</option>
                                        <option value="New Zealand" ${param.country=='New Zealand' ? 'selected' : '' }>
                                            New Zealand (+64)</option>
                                        <option value="Nicaragua" ${param.country=='Nicaragua' ? 'selected' : '' }>
                                            Nicaragua (+505)</option>
                                        <option value="Niger" ${param.country=='Niger' ? 'selected' : '' }>Niger (+227)
                                        </option>
                                        <option value="Nigeria" ${param.country=='Nigeria' ? 'selected' : '' }>Nigeria
                                            (+234)</option>
                                        <option value="North Korea" ${param.country=='North Korea' ? 'selected' : '' }>
                                            North Korea (+850)</option>
                                        <option value="Norway" ${param.country=='Norway' ? 'selected' : '' }>Norway
                                            (+47)</option>
                                        <option value="Oman" ${param.country=='Oman' ? 'selected' : '' }>Oman (+968)
                                        </option>
                                        <option value="Pakistan" ${param.country=='Pakistan' ? 'selected' : '' }>
                                            Pakistan (+92)</option>
                                        <option value="Palau" ${param.country=='Palau' ? 'selected' : '' }>Palau (+680)
                                        </option>
                                        <option value="Palestine" ${param.country=='Palestine' ? 'selected' : '' }>
                                            Palestine (+970)</option>
                                        <option value="Panama" ${param.country=='Panama' ? 'selected' : '' }>Panama
                                            (+507)</option>
                                        <option value="Papua New Guinea" ${param.country=='Papua New Guinea'
                                            ? 'selected' : '' }>Papua New Guinea (+675)</option>
                                        <option value="Paraguay" ${param.country=='Paraguay' ? 'selected' : '' }>
                                            Paraguay (+595)</option>
                                        <option value="Peru" ${param.country=='Peru' ? 'selected' : '' }>Peru (+51)
                                        </option>
                                        <option value="Philippines" ${param.country=='Philippines' ? 'selected' : '' }>
                                            Philippines (+63)</option>
                                        <option value="Poland" ${param.country=='Poland' ? 'selected' : '' }>Poland
                                            (+48)</option>
                                        <option value="Portugal" ${param.country=='Portugal' ? 'selected' : '' }>
                                            Portugal (+351)</option>
                                        <option value="Qatar" ${param.country=='Qatar' ? 'selected' : '' }>Qatar (+974)
                                        </option>
                                        <option value="Romania" ${param.country=='Romania' ? 'selected' : '' }>Romania
                                            (+40)</option>
                                        <option value="Russia" ${param.country=='Russia' ? 'selected' : '' }>Russia (+7)
                                        </option>
                                        <option value="Rwanda" ${param.country=='Rwanda' ? 'selected' : '' }>Rwanda
                                            (+250)</option>
                                        <option value="Saint Kitts and Nevis" ${param.country=='Saint Kitts and Nevis'
                                            ? 'selected' : '' }>Saint Kitts and Nevis (+1-869)</option>
                                        <option value="Saint Lucia" ${param.country=='Saint Lucia' ? 'selected' : '' }>
                                            Saint Lucia (+1-758)</option>
                                        <option value="Saint Vincent and the Grenadines"
                                            ${param.country=='Saint Vincent and the Grenadines' ? 'selected' : '' }>
                                            Saint Vincent and the Grenadines (+1-784)</option>
                                        <option value="Samoa" ${param.country=='Samoa' ? 'selected' : '' }>Samoa (+685)
                                        </option>
                                        <option value="San Marino" ${param.country=='San Marino' ? 'selected' : '' }>San
                                            Marino (+378)</option>
                                        <option value="Sao Tome and Principe" ${param.country=='Sao Tome and Principe'
                                            ? 'selected' : '' }>Sao Tome and Principe (+239)</option>
                                        <option value="Saudi Arabia" ${param.country=='Saudi Arabia' ? 'selected' : ''
                                            }>Saudi Arabia (+966)</option>
                                        <option value="Senegal" ${param.country=='Senegal' ? 'selected' : '' }>Senegal
                                            (+221)</option>
                                        <option value="Serbia" ${param.country=='Serbia' ? 'selected' : '' }>Serbia
                                            (+381)</option>
                                        <option value="Seychelles" ${param.country=='Seychelles' ? 'selected' : '' }>
                                            Seychelles (+248)</option>
                                        <option value="Sierra Leone" ${param.country=='Sierra Leone' ? 'selected' : ''
                                            }>Sierra Leone (+232)</option>
                                        <option value="Singapore" ${param.country=='Singapore' ? 'selected' : '' }>
                                            Singapore (+65)</option>
                                        <option value="Slovakia" ${param.country=='Slovakia' ? 'selected' : '' }>
                                            Slovakia (+421)</option>
                                        <option value="Slovenia" ${param.country=='Slovenia' ? 'selected' : '' }>
                                            Slovenia (+386)</option>
                                        <option value="Solomon Islands" ${param.country=='Solomon Islands' ? 'selected'
                                            : '' }>Solomon Islands (+677)</option>
                                        <option value="Somalia" ${param.country=='Somalia' ? 'selected' : '' }>Somalia
                                            (+252)</option>
                                        <option value="South Africa" ${param.country=='South Africa' ? 'selected' : ''
                                            }>South Africa (+27)</option>
                                        <option value="South Korea" ${param.country=='South Korea' ? 'selected' : '' }>
                                            South Korea (+82)</option>
                                        <option value="South Sudan" ${param.country=='South Sudan' ? 'selected' : '' }>
                                            South Sudan (+211)</option>
                                        <option value="Spain" ${param.country=='Spain' ? 'selected' : '' }>Spain (+34)
                                        </option>
                                        <option value="Sri Lanka" ${param.country=='Sri Lanka' ? 'selected' : '' }>Sri
                                            Lanka (+94)</option>
                                        <option value="Sudan" ${param.country=='Sudan' ? 'selected' : '' }>Sudan (+249)
                                        </option>
                                        <option value="Suriname" ${param.country=='Suriname' ? 'selected' : '' }>
                                            Suriname (+597)</option>
                                        <option value="Swaziland" ${param.country=='Swaziland' ? 'selected' : '' }>
                                            Swaziland (+268)</option>
                                        <option value="Sweden" ${param.country=='Sweden' ? 'selected' : '' }>Sweden
                                            (+46)</option>
                                        <option value="Switzerland" ${param.country=='Switzerland' ? 'selected' : '' }>
                                            Switzerland (+41)</option>
                                        <option value="Syria" ${param.country=='Syria' ? 'selected' : '' }>Syria (+963)
                                        </option>
                                        <option value="Taiwan" ${param.country=='Taiwan' ? 'selected' : '' }>Taiwan
                                            (+886)</option>
                                        <option value="Tajikistan" ${param.country=='Tajikistan' ? 'selected' : '' }>
                                            Tajikistan (+992)</option>
                                        <option value="Tanzania" ${param.country=='Tanzania' ? 'selected' : '' }>
                                            Tanzania (+255)</option>
                                        <option value="Thailand" ${param.country=='Thailand' ? 'selected' : '' }>
                                            Thailand (+66)</option>
                                        <option value="Timor-Leste" ${param.country=='Timor-Leste' ? 'selected' : '' }>
                                            Timor-Leste (+670)</option>
                                        <option value="Togo" ${param.country=='Togo' ? 'selected' : '' }>Togo (+228)
                                        </option>
                                        <option value="Tonga" ${param.country=='Tonga' ? 'selected' : '' }>Tonga (+676)
                                        </option>
                                        <option value="Trinidad and Tobago" ${param.country=='Trinidad and Tobago'
                                            ? 'selected' : '' }>Trinidad and Tobago (+1-868)</option>
                                        <option value="Tunisia" ${param.country=='Tunisia' ? 'selected' : '' }>Tunisia
                                            (+216)</option>
                                        <option value="Turkey" ${param.country=='Turkey' ? 'selected' : '' }>Turkey
                                            (+90)</option>
                                        <option value="Turkmenistan" ${param.country=='Turkmenistan' ? 'selected' : ''
                                            }>Turkmenistan (+993)</option>
                                        <option value="Tuvalu" ${param.country=='Tuvalu' ? 'selected' : '' }>Tuvalu
                                            (+688)</option>
                                        <option value="Uganda" ${param.country=='Uganda' ? 'selected' : '' }>Uganda
                                            (+256)</option>
                                        <option value="Ukraine" ${param.country=='Ukraine' ? 'selected' : '' }>Ukraine
                                            (+380)</option>
                                        <option value="United Arab Emirates" ${param.country=='United Arab Emirates'
                                            ? 'selected' : '' }>United Arab Emirates (+971)</option>
                                        <option value="United Kingdom" ${param.country=='United Kingdom' ? 'selected'
                                            : '' }>United Kingdom (+44)</option>
                                        <option value="United States" ${param.country=='United States' ? 'selected' : ''
                                            }>United States (+1)</option>
                                        <option value="Uruguay" ${param.country=='Uruguay' ? 'selected' : '' }>Uruguay
                                            (+598)</option>
                                        <option value="Uzbekistan" ${param.country=='Uzbekistan' ? 'selected' : '' }>
                                            Uzbekistan (+998)</option>
                                        <option value="Vanuatu" ${param.country=='Vanuatu' ? 'selected' : '' }>Vanuatu
                                            (+678)</option>
                                        <option value="Vatican City" ${param.country=='Vatican City' ? 'selected' : ''
                                            }>Vatican City (+39)</option>
                                        <option value="Venezuela" ${param.country=='Venezuela' ? 'selected' : '' }>
                                            Venezuela (+58)</option>
                                        <option value="Vietnam" ${param.country=='Vietnam' ? 'selected' : '' }>Vietnam
                                            (+84)</option>
                                        <option value="Yemen" ${param.country=='Yemen' ? 'selected' : '' }>Yemen (+967)
                                        </option>
                                        <option value="Zambia" ${param.country=='Zambia' ? 'selected' : '' }>Zambia
                                            (+260)</option>
                                        <option value="Zimbabwe" ${param.country=='Zimbabwe' ? 'selected' : '' }>
                                            Zimbabwe (+263)</option>
                                    </select>
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="state">State / Province</label>
                                    <select id="state" name="state" class="reg_select">
                                        <option value="">Select State/Province</option>
                                    </select>
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="qualification">Qualification  <span class="reg_opt">(Optional)</span></label>
                                    <input id="qualification" name="qualification" type="text"
                                        value="${param.qualification}" class="reg_input"
                                        placeholder="e.g. Bachelor's Degree">
                                </div>
                                <div class="reg_field">
                                    <label class="reg_label" for="emergencyContact">Emergency Contact
                                         <span class="reg_opt">(Optional)</span></label>
                                    <input id="emergencyContact" name="emergencyContact" type="tel"
                                        value="${param.emergencyContact}" class="reg_input" placeholder="Phone number">
                                </div>
                            </div>
                        </div>

                        <!-- Submit Button Area -->
                        <div
                            style="display: flex; flex-direction: column; gap: 16px; margin-top: 8px; border-top: 1px solid var(--reg-gray-border); padding-top: 24px;">
                            <button type="submit" class="reg_btn"
                                style="min-height: 46px; font-size: 0.95rem; display: inline-flex; align-items: center; justify-content: center; gap: 8px;">
                                <i class="fas fa-user-plus"></i>
                                <span>Create Account</span>
                            </button>
                            <p style="font-size: 0.81rem; color: var(--reg-slate-gray); text-align: center; margin: 0;">
                                Registration number is generated automatically after successful creation.
                            </p>
                            <div style="text-align: center; margin-top: 8px;">
                                <span style="font-size: 0.9rem; color: var(--reg-slate-gray);">Already have an
                                    account?</span>
                                <a href="${pageContext.request.contextPath}/login"
                                    style="font-size: 0.9rem; font-weight: 700; color: var(--reg-indigo); margin-left: 6px; text-decoration: none; border-bottom: 1px solid transparent;"
                                    onmouseover="this.style.borderBottomColor='var(--reg-indigo)'"
                                    onmouseout="this.style.borderBottomColor='transparent'">Login</a>
                            </div>
                        </div>

                    </form>
                </div>

            </div>

            <script>
                var initialCountry = '${param.country}';
                var initialState = '${param.state}';

                // State/Province mapping by country
                const statesByCountry = {
                    'United States': ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'],
                    'Canada': ['Alberta', 'British Columbia', 'Manitoba', 'New Brunswick', 'Newfoundland and Labrador', 'Northwest Territories', 'Nova Scotia', 'Nunavut', 'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan', 'Yukon'],
                    'Australia': ['Australian Capital Territory', 'New South Wales', 'Northern Territory', 'Queensland', 'South Australia', 'Tasmania', 'Victoria', 'Western Australia'],
                    'India': ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Puducherry', 'Lakshadweep', 'Daman and Diu'],
                    'Brazil': ['Acre', 'Alagoas', 'Amapá', 'Amazonas', 'Bahia', 'Ceará', 'Distrito Federal', 'Espírito Santo', 'Goiás', 'Maranhão', 'Mato Grosso', 'Mato Grosso do Sul', 'Minas Gerais', 'Pará', 'Paraíba', 'Paraná', 'Pernambuco', 'Piauí', 'Rio de Janeiro', 'Rio Grande do Norte', 'Rio Grande do Sul', 'Rondônia', 'Roraima', 'Santa Catarina', 'São Paulo', 'Sergipe', 'Tocantins'],
                    'Mexico': ['Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 'Chiapas', 'Chihuahua', 'Coahuila', 'Colima', 'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 'Mexico City', 'México', 'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León', 'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 'Veracruz', 'Yucatán', 'Zacatecas'],
                    'Nigeria': ['Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu', 'Federal Capital Territory', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara'],
                    'Tanzania': ['Arusha', 'Dar es Salaam', 'Dodoma', 'Geita', 'Iringa', 'Kagera', 'Katavi', 'Kigoma', 'Kilimanjaro', 'Lindi', 'Manyara', 'Mbeya', 'Morogoro', 'Moshi', 'Mwanza', 'Pwani', 'Ruvuma', 'Singida', 'Tabora', 'Tanga'],
                    'United Kingdom': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
                    'Germany': ['Baden-Württemberg', 'Bavaria', 'Berlin', 'Brandenburg', 'Bremen', 'Hamburg', 'Hesse', 'Lower Saxony', 'Mecklenburg-Vorpommern', 'North Rhine-Westphalia', 'Rhineland-Palatinate', 'Saarland', 'Saxony', 'Saxony-Anhalt', 'Schleswig-Holstein', 'Thuringia'],
                    'France': ['Alsace', 'Aquitaine', 'Auvergne', 'Bourgogne', 'Brittany', 'Centre', 'Champagne-Ardenne', 'Corsica', 'Franche-Comté', 'Île-de-France', 'Languedoc-Roussillon', 'Limousin', 'Lorraine', 'Midi-Pyrénées', 'Nord-Pas-de-Calais', 'Normandy', 'Pays de la Loire', 'Picardy', 'Poitou-Charentes', 'Provence-Alpes-Côte d\'Azur', 'Rhône-Alpes'],
                    'Spain': ['Andalusia', 'Aragon', 'Asturias', 'Balearic Islands', 'Basque Country', 'Canary Islands', 'Cantabria', 'Castile and León', 'Castilla-La Mancha', 'Catalonia', 'Extremadura', 'Galicia', 'La Rioja', 'Madrid', 'Murcia', 'Navarre', 'Valencia'],
                    'Italy': ['Abruzzo', 'Aosta Valley', 'Apulia', 'Basilicata', 'Calabria', 'Campania', 'Emilia-Romagna', 'Friuli Venezia Giulia', 'Lazio', 'Liguria', 'Lombardy', 'Marche', 'Molise', 'Piedmont', 'Sardinia', 'Sicily', 'Trentino-Alto Adige', 'Tuscany', 'Umbria', 'Veneto'],
                    'China': ['Anhui', 'Beijing', 'Chongqing', 'Fujian', 'Gansu', 'Guangdong', 'Guangxi', 'Guizhou', 'Hainan', 'Hebei', 'Heilongjiang', 'Henan', 'Hong Kong', 'Hubei', 'Hunan', 'Inner Mongolia', 'Jiangsu', 'Jiangxi', 'Jilin', 'Liaoning', 'Macau', 'Ningxia', 'Qinghai', 'Shaanxi', 'Shandong', 'Shanghai', 'Shanxi', 'Sichuan', 'Taiwan', 'Tianjin', 'Tibet', 'Xinjiang', 'Yunnan', 'Zhejiang'],
                    'Japan': ['Aichi', 'Akita', 'Aomori', 'Chiba', 'Ehime', 'Fukui', 'Fukuoka', 'Fukushima', 'Gifu', 'Gunma', 'Hiroshima', 'Hokkaido', 'Hyogo', 'Ibaraki', 'Ishikawa', 'Iwate', 'Kagawa', 'Kagoshima', 'Kanagawa', 'Kochi', 'Kumamoto', 'Kyoto', 'Mie', 'Miyagi', 'Miyazaki', 'Nagano', 'Nagasaki', 'Nara', 'Niigata', 'Oita', 'Okayama', 'Okinawa', 'Osaka', 'Saga', 'Saitama', 'Shiga', 'Shimane', 'Shizuoka', 'Tochigi', 'Tokushima', 'Tokyo', 'Tottori', 'Toyama', 'Wakayama', 'Yamagata', 'Yamaguchi', 'Yamanashi'],
                    'South Korea': ['Seoul', 'Busan', 'Daegu', 'Incheon', 'Gwangju', 'Daejeon', 'Ulsan', 'Gyeonggi', 'Gangwon', 'North Chungcheong', 'South Chungcheong', 'North Jeolla', 'South Jeolla', 'North Gyeongsang', 'South Gyeongsang', 'Jeju']
                };

                function populateStates(selectedCountry, selectedState) {
                    var stateSelect = document.getElementById('state');
                    var states = statesByCountry[selectedCountry] || [];

                    stateSelect.innerHTML = '<option value="">Select State/Province</option>';

                    if (!selectedCountry) {
                        return;
                    }

                    if (states.length > 0) {
                        if (selectedState && states.indexOf(selectedState) === -1) {
                            states = [selectedState].concat(states);
                        }

                        states.forEach(function (state) {
                            var option = document.createElement('option');
                            option.value = state;
                            option.textContent = state;
                            if (state === selectedState) {
                                option.selected = true;
                            }
                            stateSelect.appendChild(option);
                        });
                    } else {
                        var option = document.createElement('option');
                        option.value = '';
                        option.textContent = 'Not Applicable';
                        option.selected = true;
                        stateSelect.appendChild(option);
                    }
                }

                var countrySelect = document.getElementById('country');
                countrySelect.addEventListener('change', function () {
                    populateStates(this.value, '');
                });

                populateStates(initialCountry, initialState);

                var photoInput = document.getElementById('passportPhoto');
                var photoPreviewImage = document.getElementById('photoPreviewImage');
                var photoPlaceholder = document.getElementById('photoPlaceholder');
                var photoDropzone = document.getElementById('photoDropzone');

                function setPhotoPreview(file) {
                    if (!file) {
                        if (photoPreviewImage) {
                            photoPreviewImage.style.display = 'none';
                            photoPreviewImage.removeAttribute('src');
                        }
                        if (photoPlaceholder) {
                            photoPlaceholder.style.display = 'flex';
                        }
                        return;
                    }

                    var reader = new FileReader();
                    reader.onload = function (event) {
                        if (photoPreviewImage) {
                            photoPreviewImage.src = event.target.result;
                            photoPreviewImage.style.display = 'block';
                        }
                        if (photoPlaceholder) {
                            photoPlaceholder.style.display = 'none';
                        }
                    };
                    reader.readAsDataURL(file);
                }

                if (photoInput) {
                    photoInput.addEventListener('change', function () {
                        setPhotoPreview(this.files && this.files[0]);
                    });
                }

                if (photoDropzone && photoInput) {
                    photoDropzone.addEventListener('dragover', function (event) {
                        event.preventDefault();
                        photoDropzone.classList.add('is-dragover');
                    });

                    photoDropzone.addEventListener('dragleave', function () {
                        photoDropzone.classList.remove('is-dragover');
                    });

                    photoDropzone.addEventListener('drop', function (event) {
                        event.preventDefault();
                        photoDropzone.classList.remove('is-dragover');
                        var file = event.dataTransfer.files && event.dataTransfer.files[0];
                        if (!file) return;

                        var dataTransfer = new DataTransfer();
                        dataTransfer.items.add(file);
                        photoInput.files = dataTransfer.files;
                        setPhotoPreview(file);
                    });
                }

                // Password validation
                (function () {
                    var form = document.querySelector('form');
                    if (!form) return;
                    form.addEventListener('submit', function (e) {
                        var password = document.getElementById('password').value;
                        var confirmPassword = document.getElementById('confirmPassword').value;
                        if (password !== confirmPassword) {
                            e.preventDefault();
                            alert('Passwords do not match.');
                        }
                    });
                })();
            </script>
            <script src="${pageContext.request.contextPath}/js/auth-v2.js"></script>
        
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        });
    </script>
</body>

        </html>