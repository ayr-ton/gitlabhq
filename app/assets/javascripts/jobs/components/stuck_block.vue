<script>
import { GlLink } from '@gitlab/ui';
/**
 * Renders Stuck Runners block for job's view.
 */
export default {
  components: {
    GlLink,
  },
  props: {
    hasNoRunnersForProject: {
      type: Boolean,
      required: true,
    },
    tags: {
      type: Array,
      required: false,
      default: () => [],
    },
    runnersPath: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <div class="bs-callout bs-callout-warning">
    <p v-if="tags.length" class="gl-mb-0" data-testid="job-stuck-with-tags">
      {{
        s__(`This job is stuck because you don't have
  any active runners online or available with any of these tags assigned to them:`)
      }}
      <span
        v-for="(tag, index) in tags"
        :key="index"
        class="badge badge-primary gl-mr-2"
        data-testid="badge"
      >
        {{ tag }}
      </span>
    </p>
    <p v-else-if="hasNoRunnersForProject" class="gl-mb-0" data-testid="job-stuck-no-runners">
      {{
        s__(`Job|This job is stuck because the project
  doesn't have any runners online assigned to it.`)
      }}
    </p>
    <p v-else class="gl-mb-0" data-testid="job-stuck-no-active-runners">
      {{
        s__(`This job is stuck because you don't
  have any active runners that can run this job.`)
      }}
    </p>

    {{ __('Go to project') }}
    <gl-link v-if="runnersPath" :href="runnersPath">
      {{ __('CI settings') }}
    </gl-link>
  </div>
</template>
