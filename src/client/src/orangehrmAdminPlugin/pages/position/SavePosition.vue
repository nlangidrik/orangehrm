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
      <oxd-text tag="h6" class="orangehrm-main-title">
        Add Position
      </oxd-text>

      <oxd-divider />

      <oxd-form :loading="isLoading" @submit-valid="onSave">
        <oxd-form-row>
          <oxd-input-field
            v-model="position.name"
            label="Name"
            :rules="rules.name"
            required
          />
        </oxd-form-row>

        <oxd-form-row>
          <oxd-input-field
            v-model="position.description"
            type="textarea"
            label="Description"
            :placeholder="$t('general.type_description_here')"
            :rules="rules.description"
          />
        </oxd-form-row>

        <oxd-form-row>
          <oxd-input-field
            v-model="position.note"
            type="textarea"
            :label="$t('general.note')"
            :placeholder="$t('general.add_note')"
            label-icon="pencil-square"
            :rules="rules.note"
          />
        </oxd-form-row>

        <oxd-divider />

        <oxd-form-actions>
          <required-text />
          <oxd-button
            display-type="ghost"
            :label="$t('general.cancel')"
            @click="onCancel"
          />
          <submit-button />
        </oxd-form-actions>
      </oxd-form>
    </div>
  </div>
</template>

<script>
import {navigate} from '@ohrm/core/util/helper/navigation';
import {APIService} from '@/core/util/services/api.service';
import {
  required,
  shouldNotExceedCharLength,
} from '@ohrm/core/util/validation/rules';
import useServerValidation from '@/core/util/composable/useServerValidation';

const initialPosition = {
  name: '',
  description: '',
  note: '',
};

export default {
  setup() {
    const http = new APIService(
      window.appGlobal.baseUrl,
      '/api/v2/admin/positions',
    );
    const {createUniqueValidator} = useServerValidation(http);
    const positionUniqueValidation = createUniqueValidator(
      'Position',
      'name',
      {
        matchByField: 'isDeleted',
        matchByValue: 'false',
      },
    );

    return {
      http,
      positionUniqueValidation,
    };
  },

  data() {
    return {
      isLoading: false,
      position: {...initialPosition},
      rules: {
        name: [
          required,
          this.positionUniqueValidation,
          shouldNotExceedCharLength(100),
        ],
        description: [shouldNotExceedCharLength(400)],
        note: [shouldNotExceedCharLength(400)],
      },
    };
  },

  methods: {
    onCancel() {
      navigate('/admin/viewPositionList');
    },
    onSave() {
      this.isLoading = true;
      this.http
        .create({
          name: this.position.name,
          description: this.position.description,
          note: this.position.note,
        })
        .then(() => {
          return this.$toast.saveSuccess();
        })
        .then(() => {
          this.onCancel();
        });
    },
  },
};
</script>

