<!--
/**
 * OrangeHRM is a comprehensive Human Resource Management (HRM) System that captures
 * all the essential functionalities required for any enterprise.
 * Copyright (C) 2006 OrangeHRM Inc., http://www.orangehrm.com
 *
 * OrangeHRM is free software: you can redistribute it and/or modify it under the terms of
 * the GNU General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * OrangeHRM is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with OrangeHRM.
 * If not, see <https://www.gnu.org/licenses/>.
 */
 -->

<template>
  <div class="orangehrm-container">
    <div class="orangehrm-card-container">
      <div class="orangehrm-card-container-header">
        <oxd-text class="orangehrm-main-title" tag="h6">
          {{
            $t('recruitment.apply_for_n_vacancy', {
              vacancyName: vacancyName,
            })
          }}
        </oxd-text>
        <img class="oxd-brand-banner" :src="bannerSrc" />
      </div>
      <template v-if="vacancyDescription">
        <oxd-divider />
        <oxd-text class="orangehrm-vacancy-description" tag="p">
          {{ $t('general.description') }}
        </oxd-text>
        <oxd-text tag="p" :class="descriptionClasses">
          <pre class="orangehrm-applicant-card-pre-tag"
            >{{ vacancyDescription }}
        </pre
          >
        </oxd-text>
        <div
          v-if="vacancyDescription.length > descriptionLength"
          class="orangehrm-vacancy-card-footer"
        >
          <oxd-text
            tag="p"
            class="orangehrm-vacancy-card-anchor-tag"
            @click="onToggleMore"
          >
            {{
              isViewDetails ? $t('general.show_less') : $t('general.show_more')
            }}
          </oxd-text>
        </div>
      </template>
      <oxd-divider />
      <oxd-form
        ref="applicantForm"
        method="post"
        enctype="multipart/form-data"
        :loading="isLoading"
        :action="submitUrl"
        @submit-valid="onSave"
      >
        <input name="_token" :value="token" type="hidden" />
        <input name="vacancyId" :value="vacancyId" type="hidden" />
        <div class="orangehrm-applicant-container">
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="1" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <full-name-input
                  v-model:firstName="applicant.firstName"
                  v-model:lastName="applicant.lastName"
                  v-model:middleName="applicant.middleName"
                  :label="$t('general.full_name')"
                  :rules="rules"
                  required
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Personal Details Section Header -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-text class="orangehrm-applicant-consent" tag="h6">
              1. PERSONAL DETAILS:
            </oxd-text>
          </oxd-form-row>
          
          <!-- Social Security Number -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.socialSecurityNo"
                  name="socialSecurityNo"
                  label="Social Security No."
                  placeholder="Type here"
                  :rules="rules.socialSecurityNo"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Home Address and Phone -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item class="orangehrm-applicant-container-colspan-2">
                <oxd-input-field
                  v-model="applicant.homeAddress"
                  name="homeAddress"
                  label="Home Address"
                  placeholder="Type here"
                  :rules="rules.homeAddress"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.homePhoneNo"
                  name="homePhoneNo"
                  label="Phone No."
                  placeholder="Type here"
                  :rules="rules.homePhoneNo"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Home City, State, Zip, Cell -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.homeCity"
                  name="homeCity"
                  label="City"
                  placeholder="Type here"
                  :rules="rules.homeCity"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.homeState"
                  name="homeState"
                  label="Country/State"
                  placeholder="Type here"
                  :rules="rules.homeState"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.homeZipCode"
                  name="homeZipCode"
                  label="Zip Code"
                  placeholder="Type here"
                  :rules="rules.homeZipCode"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.cellNo"
                  name="cellNo"
                  label="Cell No."
                  placeholder="Type here"
                  :rules="rules.cellNo"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Correspondence Address and Email -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item class="orangehrm-applicant-container-colspan-2">
                <oxd-input-field
                  v-model="applicant.correspondenceAddress"
                  name="correspondenceAddress"
                  label="Correspondence Address"
                  placeholder="Type here"
                  :rules="rules.correspondenceAddress"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.email"
                  name="email"
                  :label="$t('general.email')"
                  :placeholder="$t('general.type_here')"
                  :rules="rules.email"
                  required
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Correspondence City, State, Zip, Date of Birth -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.correspondenceCity"
                  name="correspondenceCity"
                  label="City"
                  placeholder="Type here"
                  :rules="rules.correspondenceCity"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.correspondenceState"
                  name="correspondenceState"
                  label="Country/State"
                  placeholder="Type here"
                  :rules="rules.correspondenceState"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.correspondenceZipCode"
                  name="correspondenceZipCode"
                  label="Zip Code"
                  placeholder="Type here"
                  :rules="rules.correspondenceZipCode"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.dateOfBirth"
                  name="dateOfBirth"
                  label="Date of Birth"
                  type="date"
                  :display-format="'MM-dd-yyyy'"
                  :rules="rules.dateOfBirth"
                  required
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Place of Birth -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item class="orangehrm-applicant-container-colspan-2">
                <oxd-input-field
                  v-model="applicant.placeOfBirth"
                  name="placeOfBirth"
                  label="Place of Birth"
                  placeholder="Type here"
                  :rules="rules.placeOfBirth"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Gender and Marital Status -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="2" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-group label="Gender" :classes="{wrapper: '--grouped-field'}" required>
                  <oxd-input-field
                    v-model="applicant.gender"
                    type="radio"
                    option-label="Male"
                    value="1"
                  />
                  <oxd-input-field
                    v-model="applicant.gender"
                    type="radio"
                    option-label="Female"
                    value="2"
                  />
                </oxd-input-group>
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.maritalStatus"
                  name="maritalStatus"
                  label="Marital Status"
                  type="select"
                  :rules="rules.maritalStatus"
                  required
                  :options="[
                    { id: 'married', label: 'Married' },
                    { id: 'widowed', label: 'Widowed' },
                    { id: 'separated', label: 'Separated' },
                    { id: 'single', label: 'Single' },
                    { id: 'divorced', label: 'Divorced' }
                  ]"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Citizenship and Children's Ages -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="2" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-group label="Citizen of Marshalls" :classes="{wrapper: '--grouped-field'}" required>
                  <oxd-input-field
                    v-model="applicant.citizenOfMarshalls"
                    type="radio"
                    option-label="Yes"
                    value="yes"
                  />
                  <oxd-input-field
                    v-model="applicant.citizenOfMarshalls"
                    type="radio"
                    option-label="No"
                    value="no"
                  />
                </oxd-input-group>
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.childrenAges"
                  name="childrenAges"
                  label="Children's Ages"
                  placeholder="e.g., 5, 8, 12"
                  :rules="rules.childrenAges"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Nationality (if not Marshallese) -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item class="orangehrm-applicant-container-colspan-2">
                <oxd-input-field
                  v-model="applicant.nationality"
                  type="select"
                  name="nationality"
                  label="If NO, Nationality"
                  :options="nationalityOptions"
                  :rules="rules.nationality"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Next of Kin Name and Relationship -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="2" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.nextOfKinName"
                  name="nextOfKinName"
                  label="Next of Kin Name"
                  placeholder="Type here"
                  :rules="rules.nextOfKinName"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.nextOfKinRelationship"
                  name="nextOfKinRelationship"
                  label="Relationship"
                  placeholder="Type here"
                  :rules="rules.nextOfKinRelationship"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Next of Kin Address -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.nextOfKinAddress"
                  name="nextOfKinAddress"
                  label="Address"
                  placeholder="Type here"
                  :rules="rules.nextOfKinAddress"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.nextOfKinCity"
                  name="nextOfKinCity"
                  label="City"
                  placeholder="Type here"
                  :rules="rules.nextOfKinCity"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.nextOfKinState"
                  name="nextOfKinState"
                  label="Country/State"
                  placeholder="Type here"
                  :rules="rules.nextOfKinState"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.nextOfKinZipCode"
                  name="nextOfKinZipCode"
                  label="Zip Code"
                  placeholder="Type here"
                  :rules="rules.nextOfKinZipCode"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- References Section -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-text class="orangehrm-applicant-consent" tag="h6">
              2. REFERENCES:
            </oxd-text>
          </oxd-form-row>

          <!-- Reference 1 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference1FirstName"
                  name="reference1FirstName"
                  label="Reference 1 - First Name"
                  placeholder="Type here"
                  :rules="rules.reference1FirstName"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference1LastName"
                  name="reference1LastName"
                  label="Last Name"
                  placeholder="Type here"
                  :rules="rules.reference1LastName"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference1Phone"
                  name="reference1Phone"
                  label="Phone No."
                  placeholder="Type here"
                  :rules="rules.reference1Phone"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference1Email"
                  name="reference1Email"
                  label="Email Address"
                  placeholder="Type here"
                  :rules="rules.reference1Email"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Reference 2 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference2FirstName"
                  name="reference2FirstName"
                  label="Reference 2 - First Name"
                  placeholder="Type here"
                  :rules="rules.reference2FirstName"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference2LastName"
                  name="reference2LastName"
                  label="Last Name"
                  placeholder="Type here"
                  :rules="rules.reference2LastName"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference2Phone"
                  name="reference2Phone"
                  label="Phone No."
                  placeholder="Type here"
                  :rules="rules.reference2Phone"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference2Email"
                  name="reference2Email"
                  label="Email Address"
                  placeholder="Type here"
                  :rules="rules.reference2Email"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Reference 3 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference3FirstName"
                  name="reference3FirstName"
                  label="Reference 3 - First Name"
                  placeholder="Type here"
                  :rules="rules.reference3FirstName"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference3LastName"
                  name="reference3LastName"
                  label="Last Name"
                  placeholder="Type here"
                  :rules="rules.reference3LastName"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference3Phone"
                  name="reference3Phone"
                  label="Phone No."
                  placeholder="Type here"
                  :rules="rules.reference3Phone"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.reference3Email"
                  name="reference3Email"
                  label="Email Address"
                  placeholder="Type here"
                  :rules="rules.reference3Email"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Training/Workshops Section -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-text class="orangehrm-applicant-consent" tag="h6">
              3. TRAINING COURSES, WORKSHOPS OR SEMINARS ATTENDED:
            </oxd-text>
          </oxd-form-row>

          <!-- Training 1 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training1Title"
                  name="training1Title"
                  label="Course Title"
                  placeholder="Type here"
                  :rules="rules.training1Title"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training1From"
                  name="training1From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.training1From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training1To"
                  name="training1To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.training1To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training1Location"
                  name="training1Location"
                  label="Location"
                  placeholder="Type here"
                  :rules="rules.training1Location"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Training 2 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training2Title"
                  name="training2Title"
                  label="Course Title"
                  placeholder="Type here"
                  :rules="rules.training2Title"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training2From"
                  name="training2From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.training2From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training2To"
                  name="training2To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.training2To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training2Location"
                  name="training2Location"
                  label="Location"
                  placeholder="Type here"
                  :rules="rules.training2Location"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Training 3 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training3Title"
                  name="training3Title"
                  label="Course Title"
                  placeholder="Type here"
                  :rules="rules.training3Title"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training3From"
                  name="training3From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.training3From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training3To"
                  name="training3To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.training3To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training3Location"
                  name="training3Location"
                  label="Location"
                  placeholder="Type here"
                  :rules="rules.training3Location"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Training 4 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training4Title"
                  name="training4Title"
                  label="Course Title"
                  placeholder="Type here"
                  :rules="rules.training4Title"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training4From"
                  name="training4From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.training4From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training4To"
                  name="training4To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.training4To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.training4Location"
                  name="training4Location"
                  label="Location"
                  placeholder="Type here"
                  :rules="rules.training4Location"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Education Section -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-text class="orangehrm-applicant-consent" tag="h6">
              4. FORMAL EDUCATION (List in Date Order):
            </oxd-text>
          </oxd-form-row>

          <!-- High School Header -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-text tag="p" style="font-weight: 600;">
              High School Attended:
            </oxd-text>
          </oxd-form-row>

          <!-- High School 1 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool1Name"
                  name="highSchool1Name"
                  label="School Name"
                  placeholder="Type here"
                  :rules="rules.highSchool1Name"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool1From"
                  name="highSchool1From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.highSchool1From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool1To"
                  name="highSchool1To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.highSchool1To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool1Grade"
                  name="highSchool1Grade"
                  label="Highest Grade/Diploma"
                  placeholder="Type here"
                  :rules="rules.highSchool1Grade"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- High School 2 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool2Name"
                  name="highSchool2Name"
                  label="School Name"
                  placeholder="Type here"
                  :rules="rules.highSchool2Name"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool2From"
                  name="highSchool2From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.highSchool2From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool2To"
                  name="highSchool2To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.highSchool2To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool2Grade"
                  name="highSchool2Grade"
                  label="Highest Grade/Diploma"
                  placeholder="Type here"
                  :rules="rules.highSchool2Grade"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- High School 3 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="4" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool3Name"
                  name="highSchool3Name"
                  label="School Name"
                  placeholder="Type here"
                  :rules="rules.highSchool3Name"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool3From"
                  name="highSchool3From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.highSchool3From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool3To"
                  name="highSchool3To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.highSchool3To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.highSchool3Grade"
                  name="highSchool3Grade"
                  label="Highest Grade/Diploma"
                  placeholder="Type here"
                  :rules="rules.highSchool3Grade"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- College Header -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-text tag="p" style="font-weight: 600;">
              College or University Attended:
            </oxd-text>
          </oxd-form-row>

          <!-- College 1 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="5" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college1Name"
                  name="college1Name"
                  label="College/University"
                  placeholder="Type here"
                  :rules="rules.college1Name"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college1From"
                  name="college1From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.college1From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college1To"
                  name="college1To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.college1To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college1Major"
                  name="college1Major"
                  label="Major"
                  placeholder="Type here"
                  :rules="rules.college1Major"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college1Degree"
                  name="college1Degree"
                  label="Degree/Credit Hours"
                  placeholder="Type here"
                  :rules="rules.college1Degree"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- College 2 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="5" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college2Name"
                  name="college2Name"
                  label="College/University"
                  placeholder="Type here"
                  :rules="rules.college2Name"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college2From"
                  name="college2From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.college2From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college2To"
                  name="college2To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.college2To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college2Major"
                  name="college2Major"
                  label="Major"
                  placeholder="Type here"
                  :rules="rules.college2Major"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college2Degree"
                  name="college2Degree"
                  label="Degree/Credit Hours"
                  placeholder="Type here"
                  :rules="rules.college2Degree"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- College 3 -->
          <oxd-form-row class="orangehrm-applicant-container-row">
            <oxd-grid :cols="5" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college3Name"
                  name="college3Name"
                  label="College/University"
                  placeholder="Type here"
                  :rules="rules.college3Name"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college3From"
                  name="college3From"
                  label="From"
                  placeholder="Type here"
                  :rules="rules.college3From"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college3To"
                  name="college3To"
                  label="To"
                  placeholder="Type here"
                  :rules="rules.college3To"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college3Major"
                  name="college3Major"
                  label="Major"
                  placeholder="Type here"
                  :rules="rules.college3Major"
                />
              </oxd-grid-item>
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.college3Degree"
                  name="college3Degree"
                  label="Degree/Credit Hours"
                  placeholder="Type here"
                  :rules="rules.college3Degree"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>

          <!-- Contact Number (original field kept for compatibility) -->
          <oxd-form-row class="orangehrm-applicant-container-row" style="display:none;">
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.contactNumber"
                  name="contactNumber"
                  :label="$t('recruitment.contact_number')"
                  :placeholder="$t('general.type_here')"
                  :rules="rules.contactNumber"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>
          <oxd-form-row>
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item>
                <oxd-input-field
                  v-model="applicant.resume"
                  name="resume"
                  type="file"
                  :label="$t('recruitment.resume')"
                  :button-label="$t('general.browse')"
                  :rules="rules.resume"
                  required
                />
                <oxd-text class="orangehrm-input-hint" tag="p">
                  {{
                    $t('general.accept_custom_format_file_up_to_n_mb', {
                      count: formattedFileSize,
                    })
                  }}
                </oxd-text>
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>
          <oxd-form-row>
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item class="orangehrm-applicant-container-colspan-2">
                <oxd-input-field
                  v-model="applicant.keywords"
                  name="keywords"
                  :label="$t('recruitment.keywords')"
                  :placeholder="`${$t(
                    'recruitment.enter_comma_seperated_words',
                  )}...`"
                  :rules="rules.keywords"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>
          <oxd-form-row>
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item class="orangehrm-applicant-container-colspan-2">
                <oxd-input-field
                  v-model="applicant.comment"
                  name="comment"
                  :label="$t('general.notes')"
                  type="textarea"
                  :placeholder="$t('general.type_here')"
                  :rules="rules.comment"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>
          <oxd-form-row>
            <oxd-grid :cols="3" class="orangehrm-full-width-grid">
              <oxd-grid-item
                class="orangehrm-applicant-container-colspan-2 orangehrm-applicant-container-grid-checkbox"
              >
                <oxd-input-field
                  v-model="applicant.consentToKeepData"
                  name="consentToKeepData"
                  :label="$t('recruitment.consent_to_keep_data')"
                  type="checkbox"
                />
              </oxd-grid-item>
            </oxd-grid>
          </oxd-form-row>
          <oxd-divider />
          <oxd-form-actions>
            <required-text />
            <oxd-button
              :label="$t('general.back')"
              display-type="ghost"
              @click="onCancel"
            />
            <submit-button :label="$t('general.submit')" />
          </oxd-form-actions>
        </div>
      </oxd-form>
    </div>
  </div>
  <div class="orangehrm-paper-container">
    <oxd-text tag="p" class="orangehrm-vacancy-list-poweredby">
      {{ $t('recruitment.powered_by') }}
    </oxd-text>
    <img
      :src="defaultPic"
      alt="OrangeHRM Picture"
      class="orangehrm-container-img"
    />
    <slot name="footer"></slot>
  </div>
  <success-dialogue ref="showDialogueModal"></success-dialogue>
</template>

<script>
import {ref, toRefs, onBeforeMount} from 'vue';
import FullNameInput from '@/orangehrmPimPlugin/components/FullNameInput';
import SuccessDialog from '@/orangehrmRecruitmentPlugin/components/SuccessDialog';
import {
  maxFileSize,
  required,
  shouldNotExceedCharLength,
  validEmailFormat,
  validFileTypes,
  validPhoneNumberFormat,
} from '@ohrm/core/util/validation/rules';
import SubmitButton from '@/core/components/buttons/SubmitButton';
import {navigate} from '@/core/util/helper/navigation';
import {APIService} from '@/core/util/services/api.service';
import {urlFor} from '@/core/util/helper/url';
import {useResponsive, OxdInputGroup} from '@ohrm/oxd';

const applicantModel = {
  firstName: '',
  middleName: '',
  lastName: '',
  contactNumber: '',
  email: '',
  consentToKeepData: false,
  resume: null,
  keywords: null,
  comment: null,
  // Additional Personal Details for PSS
  socialSecurityNo: '',
  homeAddress: '',
  homeCity: '',
  homeState: '',
  homeZipCode: '',
  homePhoneNo: '',
  cellNo: '',
  correspondenceAddress: '',
  correspondenceCity: '',
  correspondenceState: '',
  correspondenceZipCode: '',
  emailAddress: '',
  dateOfBirth: '',
  placeOfBirth: '',
  gender: '',
  maritalStatus: '',
  citizenOfMarshalls: '',
  nationality: '',
  childrenAges: '',
  nextOfKinName: '',
  nextOfKinRelationship: '',
  nextOfKinAddress: '',
  nextOfKinCity: '',
  nextOfKinState: '',
  nextOfKinZipCode: '',
  // References
  reference1FirstName: '',
  reference1LastName: '',
  reference1Phone: '',
  reference1Email: '',
  reference2FirstName: '',
  reference2LastName: '',
  reference2Phone: '',
  reference2Email: '',
  reference3FirstName: '',
  reference3LastName: '',
  reference3Phone: '',
  reference3Email: '',
  // Training/Workshops (4 entries)
  training1Title: '',
  training1From: '',
  training1To: '',
  training1Location: '',
  training2Title: '',
  training2From: '',
  training2To: '',
  training2Location: '',
  training3Title: '',
  training3From: '',
  training3To: '',
  training3Location: '',
  training4Title: '',
  training4From: '',
  training4To: '',
  training4Location: '',
  // High School (3 entries)
  highSchool1Name: '',
  highSchool1From: '',
  highSchool1To: '',
  highSchool1Grade: '',
  highSchool2Name: '',
  highSchool2From: '',
  highSchool2To: '',
  highSchool2Grade: '',
  highSchool3Name: '',
  highSchool3From: '',
  highSchool3To: '',
  highSchool3Grade: '',
  // College/University (3 entries)
  college1Name: '',
  college1From: '',
  college1To: '',
  college1Major: '',
  college1Degree: '',
  college2Name: '',
  college2From: '',
  college2To: '',
  college2Major: '',
  college2Degree: '',
  college3Name: '',
  college3From: '',
  college3To: '',
  college3Major: '',
  college3Degree: '',
};

export default {
  name: 'ApplyJobVacancy',
  components: {
    'submit-button': SubmitButton,
    'full-name-input': FullNameInput,
    'success-dialogue': SuccessDialog,
    'oxd-input-group': OxdInputGroup,
  },
  props: {
    allowedFileTypes: {
      type: Array,
      required: true,
    },
    maxFileSize: {
      type: Number,
      required: true,
    },
    vacancyId: {
      type: Number,
      required: true,
    },
    success: {
      type: Boolean,
      default: false,
    },
    bannerSrc: {
      type: String,
      required: true,
    },
    token: {
      type: String,
      required: true,
    },
  },
  setup() {
    const defaultPic = `${window.appGlobal.publicPath}/images/ohrm_branding.png`;
    const applicant = ref({
      ...applicantModel,
    });
    const responsiveState = useResponsive();
    const http = new APIService(
      window.appGlobal.baseUrl,
      '/api/v2/recruitment/public/vacancies',
    );
    
    // HTTP service for submitting applications
    const applicantHttp = new APIService(
      window.appGlobal.baseUrl,
      '/recruitment/public/applicants',
    );
    
    // Fetch nationality options
    const nationalityOptions = ref([]);
    const nationalityHttp = new APIService(
      window.appGlobal.baseUrl,
      '/api/v2/admin/nationalities',
    );
    onBeforeMount(() => {
      nationalityHttp.getAll({limit: 0}).then(({data}) => {
        nationalityOptions.value = data.data.map((item) => {
          return {
            id: item.id,
            label: item.name || item.label, // Use name, fallback to label
          };
        });
      });
    });

    return {
      http,
      applicantHttp,
      applicant,
      defaultPic,
      nationalityOptions,
      ...toRefs(responsiveState),
    };
  },
  data() {
    return {
      title: null,
      subtitle: null,
      successLabel: null,
      isLoading: false,
      vacancyName: '',
      vacancyDescription: null,
      rules: {
        firstName: [required, shouldNotExceedCharLength(30)],
        middleName: [shouldNotExceedCharLength(30)],
        lastName: [required, shouldNotExceedCharLength(30)],
        resume: [
          required,
          maxFileSize(this.maxFileSize),
          validFileTypes(this.allowedFileTypes),
        ],
        comment: [], // No length limit - contains PSS custom data
        keywords: [shouldNotExceedCharLength(250)],
        contactNumber: [shouldNotExceedCharLength(25), validPhoneNumberFormat],
        email: [required, validEmailFormat, shouldNotExceedCharLength(50)],
        // Additional field validations for PSS
        socialSecurityNo: [shouldNotExceedCharLength(20)],
        homeAddress: [shouldNotExceedCharLength(250)],
        homeCity: [shouldNotExceedCharLength(50)],
        homeState: [shouldNotExceedCharLength(50)],
        homeZipCode: [shouldNotExceedCharLength(10)],
        homePhoneNo: [shouldNotExceedCharLength(25), validPhoneNumberFormat],
        cellNo: [shouldNotExceedCharLength(25), validPhoneNumberFormat],
        correspondenceAddress: [shouldNotExceedCharLength(250)],
        correspondenceCity: [shouldNotExceedCharLength(50)],
        correspondenceState: [shouldNotExceedCharLength(50)],
        correspondenceZipCode: [shouldNotExceedCharLength(10)],
        emailAddress: [validEmailFormat, shouldNotExceedCharLength(50)],
        dateOfBirth: [required],
        placeOfBirth: [shouldNotExceedCharLength(100)],
        gender: [required],
        maritalStatus: [required],
        citizenOfMarshalls: [required],
        nationality: [shouldNotExceedCharLength(50)],
        childrenAges: [shouldNotExceedCharLength(100)],
        nextOfKinName: [shouldNotExceedCharLength(100)],
        nextOfKinRelationship: [shouldNotExceedCharLength(50)],
        nextOfKinAddress: [shouldNotExceedCharLength(250)],
        nextOfKinCity: [shouldNotExceedCharLength(50)],
        nextOfKinState: [shouldNotExceedCharLength(50)],
        nextOfKinZipCode: [shouldNotExceedCharLength(10)],
        // References validation
        reference1FirstName: [shouldNotExceedCharLength(100)],
        reference1LastName: [shouldNotExceedCharLength(100)],
        reference1Phone: [shouldNotExceedCharLength(25), validPhoneNumberFormat],
        reference1Email: [validEmailFormat, shouldNotExceedCharLength(50)],
        reference2FirstName: [shouldNotExceedCharLength(100)],
        reference2LastName: [shouldNotExceedCharLength(100)],
        reference2Phone: [shouldNotExceedCharLength(25), validPhoneNumberFormat],
        reference2Email: [validEmailFormat, shouldNotExceedCharLength(50)],
        reference3FirstName: [shouldNotExceedCharLength(100)],
        reference3LastName: [shouldNotExceedCharLength(100)],
        reference3Phone: [shouldNotExceedCharLength(25), validPhoneNumberFormat],
        reference3Email: [validEmailFormat, shouldNotExceedCharLength(50)],
        // Training validation
        training1Title: [shouldNotExceedCharLength(100)],
        training1From: [shouldNotExceedCharLength(20)],
        training1To: [shouldNotExceedCharLength(20)],
        training1Location: [shouldNotExceedCharLength(100)],
        training2Title: [shouldNotExceedCharLength(100)],
        training2From: [shouldNotExceedCharLength(20)],
        training2To: [shouldNotExceedCharLength(20)],
        training2Location: [shouldNotExceedCharLength(100)],
        training3Title: [shouldNotExceedCharLength(100)],
        training3From: [shouldNotExceedCharLength(20)],
        training3To: [shouldNotExceedCharLength(20)],
        training3Location: [shouldNotExceedCharLength(100)],
        training4Title: [shouldNotExceedCharLength(100)],
        training4From: [shouldNotExceedCharLength(20)],
        training4To: [shouldNotExceedCharLength(20)],
        training4Location: [shouldNotExceedCharLength(100)],
        // High School validation
        highSchool1Name: [shouldNotExceedCharLength(100)],
        highSchool1From: [shouldNotExceedCharLength(20)],
        highSchool1To: [shouldNotExceedCharLength(20)],
        highSchool1Grade: [shouldNotExceedCharLength(50)],
        highSchool2Name: [shouldNotExceedCharLength(100)],
        highSchool2From: [shouldNotExceedCharLength(20)],
        highSchool2To: [shouldNotExceedCharLength(20)],
        highSchool2Grade: [shouldNotExceedCharLength(50)],
        highSchool3Name: [shouldNotExceedCharLength(100)],
        highSchool3From: [shouldNotExceedCharLength(20)],
        highSchool3To: [shouldNotExceedCharLength(20)],
        highSchool3Grade: [shouldNotExceedCharLength(50)],
        // College validation
        college1Name: [shouldNotExceedCharLength(100)],
        college1From: [shouldNotExceedCharLength(20)],
        college1To: [shouldNotExceedCharLength(20)],
        college1Major: [shouldNotExceedCharLength(50)],
        college1Degree: [shouldNotExceedCharLength(100)],
        college2Name: [shouldNotExceedCharLength(100)],
        college2From: [shouldNotExceedCharLength(20)],
        college2To: [shouldNotExceedCharLength(20)],
        college2Major: [shouldNotExceedCharLength(50)],
        college2Degree: [shouldNotExceedCharLength(100)],
        college3Name: [shouldNotExceedCharLength(100)],
        college3From: [shouldNotExceedCharLength(20)],
        college3To: [shouldNotExceedCharLength(20)],
        college3Major: [shouldNotExceedCharLength(50)],
        college3Degree: [shouldNotExceedCharLength(100)],
      },
      isViewDetails: true,
    };
  },
  computed: {
    compiledComment() {
      // Compile all PSS custom fields into comment
      const pssDetails = [];
      if (this.applicant.socialSecurityNo) pssDetails.push(`SSN: ${this.applicant.socialSecurityNo}`);
      if (this.applicant.dateOfBirth) pssDetails.push(`DOB: ${this.applicant.dateOfBirth}`);
      if (this.applicant.placeOfBirth) pssDetails.push(`Place of Birth: ${this.applicant.placeOfBirth}`);
      if (this.applicant.gender) pssDetails.push(`Gender: ${this.applicant.gender === '1' ? 'Male' : 'Female'}`);
      if (this.applicant.maritalStatus) {
        const maritalValue = typeof this.applicant.maritalStatus === 'object' 
          ? this.applicant.maritalStatus.label 
          : this.applicant.maritalStatus;
        pssDetails.push(`Marital Status: ${maritalValue}`);
      }
      if (this.applicant.homeAddress) pssDetails.push(`Home: ${this.applicant.homeAddress}, ${this.applicant.homeCity}, ${this.applicant.homeState} ${this.applicant.homeZipCode}`);
      if (this.applicant.homePhoneNo) pssDetails.push(`Home Phone: ${this.applicant.homePhoneNo}`);
      if (this.applicant.cellNo) pssDetails.push(`Cell: ${this.applicant.cellNo}`);
      if (this.applicant.correspondenceAddress) pssDetails.push(`Correspondence: ${this.applicant.correspondenceAddress}, ${this.applicant.correspondenceCity}, ${this.applicant.correspondenceState} ${this.applicant.correspondenceZipCode}`);
      if (this.applicant.citizenOfMarshalls) pssDetails.push(`Citizen of Marshalls: ${this.applicant.citizenOfMarshalls}`);
      if (this.applicant.nationality) {
        const nationalityValue = typeof this.applicant.nationality === 'object' 
          ? this.applicant.nationality.label 
          : this.applicant.nationality;
        pssDetails.push(`Nationality: ${nationalityValue}`);
      }
      if (this.applicant.childrenAges) pssDetails.push(`Children's Ages: ${this.applicant.childrenAges}`);
      if (this.applicant.nextOfKinName) pssDetails.push(`Next of Kin: ${this.applicant.nextOfKinName} (${this.applicant.nextOfKinRelationship})`);
      if (this.applicant.nextOfKinAddress) pssDetails.push(`NOK Address: ${this.applicant.nextOfKinAddress}, ${this.applicant.nextOfKinCity}, ${this.applicant.nextOfKinState} ${this.applicant.nextOfKinZipCode}`);
      
      // Add References section
      const references = [];
      if (this.applicant.reference1FirstName || this.applicant.reference1LastName) {
        references.push(`Ref 1: ${this.applicant.reference1FirstName} ${this.applicant.reference1LastName}, ${this.applicant.reference1Phone}, ${this.applicant.reference1Email}`);
      }
      if (this.applicant.reference2FirstName || this.applicant.reference2LastName) {
        references.push(`Ref 2: ${this.applicant.reference2FirstName} ${this.applicant.reference2LastName}, ${this.applicant.reference2Phone}, ${this.applicant.reference2Email}`);
      }
      if (this.applicant.reference3FirstName || this.applicant.reference3LastName) {
        references.push(`Ref 3: ${this.applicant.reference3FirstName} ${this.applicant.reference3LastName}, ${this.applicant.reference3Phone}, ${this.applicant.reference3Email}`);
      }
      
      // Add Training/Workshops section
      const training = [];
      if (this.applicant.training1Title) {
        training.push(`1. ${this.applicant.training1Title} | ${this.applicant.training1From} - ${this.applicant.training1To} | ${this.applicant.training1Location}`);
      }
      if (this.applicant.training2Title) {
        training.push(`2. ${this.applicant.training2Title} | ${this.applicant.training2From} - ${this.applicant.training2To} | ${this.applicant.training2Location}`);
      }
      if (this.applicant.training3Title) {
        training.push(`3. ${this.applicant.training3Title} | ${this.applicant.training3From} - ${this.applicant.training3To} | ${this.applicant.training3Location}`);
      }
      if (this.applicant.training4Title) {
        training.push(`4. ${this.applicant.training4Title} | ${this.applicant.training4From} - ${this.applicant.training4To} | ${this.applicant.training4Location}`);
      }
      
      // Add Education section
      const education = [];
      // High Schools
      const highSchools = [];
      if (this.applicant.highSchool1Name) {
        highSchools.push(`${this.applicant.highSchool1Name} | ${this.applicant.highSchool1From} - ${this.applicant.highSchool1To} | Grade: ${this.applicant.highSchool1Grade}`);
      }
      if (this.applicant.highSchool2Name) {
        highSchools.push(`${this.applicant.highSchool2Name} | ${this.applicant.highSchool2From} - ${this.applicant.highSchool2To} | Grade: ${this.applicant.highSchool2Grade}`);
      }
      if (this.applicant.highSchool3Name) {
        highSchools.push(`${this.applicant.highSchool3Name} | ${this.applicant.highSchool3From} - ${this.applicant.highSchool3To} | Grade: ${this.applicant.highSchool3Grade}`);
      }
      if (highSchools.length > 0) {
        education.push(`High School:\n${highSchools.join('\n')}`);
      }
      
      // Colleges
      const colleges = [];
      if (this.applicant.college1Name) {
        colleges.push(`${this.applicant.college1Name} | ${this.applicant.college1From} - ${this.applicant.college1To} | Major: ${this.applicant.college1Major} | ${this.applicant.college1Degree}`);
      }
      if (this.applicant.college2Name) {
        colleges.push(`${this.applicant.college2Name} | ${this.applicant.college2From} - ${this.applicant.college2To} | Major: ${this.applicant.college2Major} | ${this.applicant.college2Degree}`);
      }
      if (this.applicant.college3Name) {
        colleges.push(`${this.applicant.college3Name} | ${this.applicant.college3From} - ${this.applicant.college3To} | Major: ${this.applicant.college3Major} | ${this.applicant.college3Degree}`);
      }
      if (colleges.length > 0) {
        education.push(`College/University:\n${colleges.join('\n')}`);
      }
      
      const originalComment = this.applicant.comment || '';
      const pssData = pssDetails.join('\n');
      const referencesData = references.length > 0 ? `\n\n=== References ===\n${references.join('\n')}` : '';
      const trainingData = training.length > 0 ? `\n\n=== Training/Workshops ===\n${training.join('\n')}` : '';
      const educationData = education.length > 0 ? `\n\n=== Education ===\n${education.join('\n\n')}` : '';
      return originalComment 
        ? `${originalComment}\n\n=== Personal Details ===\n${pssData}${referencesData}${trainingData}${educationData}` 
        : `=== Personal Details ===\n${pssData}${referencesData}${trainingData}${educationData}`;
    },
    submitUrl() {
      return `${window.appGlobal.baseUrl}/recruitment/public/applicants`;
    },
    descriptionClasses() {
      return {
        'orangehrm-vacancy-description': true,
        'orangehrm-vacancy-card-body': !this.isViewDetails,
      };
    },
    isMobile() {
      return this.windowWidth < 600;
    },
    descriptionLength() {
      if (this.isMobile) return 150;
      return this.windowWidth < 1920 ? 250 : 400;
    },
    formattedFileSize() {
      return Math.round((this.maxFileSize / (1024 * 1024)) * 100) / 100;
    },
  },
  beforeMount() {
    this.http.get(this.vacancyId).then((response) => {
      const {data} = response.data;
      this.vacancyName = data?.name ?? '';
      this.vacancyDescription = data?.description;
    });
  },
  mounted() {
    if (this.success) {
      this.showDialogue();
    }
  },
  methods: {
    onSave() {
      // Compile PSS data and update comment field
      this.applicant.comment = this.compiledComment;
      
      // Use cell number as contact number if not provided
      if (!this.applicant.contactNumber && this.applicant.cellNo) {
        this.applicant.contactNumber = this.applicant.cellNo;
      }
      
      // Wait for Vue to update DOM, then submit form manually
      this.$nextTick(() => {
        const form = this.$refs.applicantForm.$el;
        if (form && form.tagName === 'FORM') {
          form.submit();
        }
      });
      
      // Prevent default submission - we'll submit manually after updating comment
      return false;
    },
    onCancel() {
      navigate('/recruitmentApply/jobs.html');
    },
    showDialogue() {
      this.$refs.showDialogueModal.showSuccessDialog().then((confirmation) => {
        if (confirmation === 'ok') {
          navigate('/recruitmentApply/jobs.html');
        }
      });
    },
    onToggleMore() {
      this.isViewDetails = !this.isViewDetails;
    },
  },
};
</script>

<style src="./public-job-vacancy.scss" lang="scss" scoped></style>
