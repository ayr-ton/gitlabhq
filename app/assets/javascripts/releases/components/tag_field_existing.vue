<script>
import { mapState } from 'vuex';
import { uniqueId } from 'lodash';
import { GlFormGroup, GlFormInput, GlLink, GlSprintf } from '@gitlab/ui';

export default {
  name: 'TagFieldExisting',
  components: { GlFormGroup, GlFormInput, GlSprintf, GlLink },
  computed: {
    ...mapState('detail', ['release', 'updateReleaseApiDocsPath']),
    inputId() {
      return uniqueId('tag-name-input-');
    },
    helpId() {
      return uniqueId('tag-name-help-');
    },
  },
};
</script>
<template>
  <gl-form-group :label="__('Tag name')" :label-for="inputId">
    <div class="row">
      <div class="col-md-6 col-lg-5 col-xl-4">
        <gl-form-input
          :id="inputId"
          :value="release.tagName"
          type="text"
          class="form-control"
          :aria-describedby="helpId"
          disabled
        />
      </div>
    </div>
    <template #description>
      <div :id="helpId" data-testid="tag-name-help">
        <gl-sprintf
          :message="
            __(
              'Changing a Release tag is only supported via Releases API. %{linkStart}More information%{linkEnd}',
            )
          "
        >
          <template #link="{ content }">
            <gl-link :href="updateReleaseApiDocsPath" target="_blank">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </div>
    </template>
  </gl-form-group>
</template>
