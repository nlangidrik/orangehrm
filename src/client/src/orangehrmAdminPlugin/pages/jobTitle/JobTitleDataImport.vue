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
  <div class="orangehrm-background-container">
    <div class="orangehrm-card-container">
      <oxd-text class="orangehrm-main-title">
        {{ $t('admin.job_title_data_import') }}
      </oxd-text>

      <oxd-divider />
      <div class="orangehrm-information-card-container">
        <oxd-text class="orangehrm-sub-title">
          {{ $t('general.note') }}:
        </oxd-text>
        <ul>
          <li>
            <oxd-text class="orangehrm-information-card-text">
              {{ $t('admin.column_order_should_not_be_changed') }}
            </oxd-text>
          </li>
          <li>
            <oxd-text class="orangehrm-information-card-text">
              {{ $t('admin.job_title_is_compulsory') }}
            </oxd-text>
          </li>
          <li>
            <oxd-text class="orangehrm-information-card-text">
              {{ $t('admin.job_title_name_max_length_100') }}
            </oxd-text>
          </li>
          <li>
            <oxd-text class="orangehrm-information-card-text">
              {{ $t('admin.job_description_max_length_400') }}
            </oxd-text>
          </li>
          <li>
            <oxd-text class="orangehrm-information-card-text">
              {{ $t('admin.note_max_length_400') }}
            </oxd-text>
          </li>
          <li>
            <oxd-text class="orangehrm-information-card-text">
              {{ $t('admin.duplicate_job_titles_will_be_skipped') }}
            </oxd-text>
          </li>
          <li>
            <oxd-text class="orangehrm-information-card-text">
              {{ $t('admin.sample_csv_file') }} :
              <a
                href="#"
                class="download-link"
                @click.prevent="onClickDownload"
              >
                {{ $t('general.download') }}
              </a>
            </oxd-text>
          </li>
        </ul>
      </div>
      <br />

      <oxd-form ref="formRef" :loading="isLoading" @submit-valid="onSave">
        <oxd-form-row>
          <oxd-grid :cols="3" class="orangehrm-full-width-grid">
            <oxd-grid-item>
              <oxd-input-field
                v-model="attachment.attachment"
                type="file"
                :rules="rules.attachment"
                :label="$t('general.select_file')"
                :button-label="$t('general.browse')"
                :placeholder="$t('general.no_file_selected')"
                required
              />
              <oxd-text class="orangehrm-input-hint" tag="p">
                {{
                  $t('general.accepts_up_to_n_mb', {count: formattedFileSize})
                }}
              </oxd-text>
            </oxd-grid-item>
          </oxd-grid>
        </oxd-form-row>

        <oxd-divider />
        <oxd-form-actions>
          <required-text />
          <submit-button :label="$t('general.upload')" />
        </oxd-form-actions>
      </oxd-form>
    </div>
    <job-title-data-import-modal
      v-if="importModalState"
      :data="importModalState"
      @close="onImportModalClose"
    ></job-title-data-import-modal>
  </div>
</template>

<script>
import {
  required,
  maxFileSize,
  validFileTypes,
} from '@/core/util/validation/rules';
import useForm from '@ohrm/core/util/composable/useForm';
import {APIService} from '@/core/util/services/api.service';
import JobTitleDataImportModal from '@/orangehrmAdminPlugin/components/JobTitleDataImportModal';

const attachmentModel = {
  attachment: null,
};

export default {
  components: {
    'job-title-data-import-modal': JobTitleDataImportModal,
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
  },
  setup() {
    const http = new APIService(
      window.appGlobal.baseUrl,
      `/api/v2/admin/job-titles/csv-import`,
    );
    const {formRef, reset} = useForm();
    return {
      http,
      reset,
      formRef,
    };
  },

  data() {
    return {
      isLoading: false,
      attachment: {
        ...attachmentModel,
      },
      rules: {
        attachment: [
          required,
          maxFileSize(this.maxFileSize),
          validFileTypes(this.allowedFileTypes),
        ],
      },
      importModalState: null,
    };
  },
  computed: {
    formattedFileSize() {
      return Math.round((this.maxFileSize / (1024 * 1024)) * 100) / 100;
    },
  },
  methods: {
    onSave() {
      this.isLoading = true;
      this.http
        .create({
          ...this.attachment,
        })
        .then((response) => {
          const {meta} = response.data;
          this.importModalState = meta;
        })
        .finally(() => {
          this.reset();
          this.isLoading = false;
        });
    },
    onClickDownload() {
      const downUrl = `${window.appGlobal.baseUrl}/admin/jobTitle/sampleCsvDownload`;
      window.open(downUrl, '_blank');
    },
    onImportModalClose() {
      this.importModalState = null;
    },
  },
};
</script>

<style lang="scss" scoped>
.orangehrm-information-card-container {
  background-color: $oxd-interface-gray-lighten-2-color;
  border-radius: 1.2rem;
  padding: 1.2rem;
}
.orangehrm-information-card-text {
  font-size: $oxd-input-control-font-size;
  color: $oxd-input-control-font-color;
  font-weight: $oxd-input-control-font-weight;
  & .download-link {
    color: $oxd-primary-one-color;
  }
}
</style>

