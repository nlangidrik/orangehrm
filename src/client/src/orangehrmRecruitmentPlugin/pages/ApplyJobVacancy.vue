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
      
      const originalComment = this.applicant.comment || '';
      const pssData = pssDetails.join('\n');
      return originalComment ? `${originalComment}\n\n=== Personal Details ===\n${pssData}` : `=== Personal Details ===\n${pssData}`;
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
      
      // Wait for Vue to update DOM, then submit
      this.$nextTick(() => {
        this.$refs.applicantForm.$el.submit();
      });
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
