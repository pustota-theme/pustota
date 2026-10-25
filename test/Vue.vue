<template>
  <main :class="$style.main">
    <app-logo />
    <action-bar />

    <section
      name="string"
      v-if="typedStore.comments.hasComments"
      :class="$style.container"
    >
      <comment
        v-for="comment in typedStore.comments.comments"
        :key="comment.id"
        :comment="comment"
        @event="abc"
      />
    </section>
    <header :class="[$style.header, { [$style.sticky]: isSticky }]" v-once>
      <h1 v-text="title" />
      <small>{{ comments.length }} / {{ total.toLocaleString() }} ({{ (progress * 100).toFixed(1) }}%)</small>
    </header>

    <form @submit.prevent="submit" @keydown.esc.stop="reset" :[attrName]="attrValue">
      <label :for="inputId">Name</label>
      <input
        :id="inputId"
        v-model.trim="form.name"
        type="text"
        :placeholder="`Hello, ${form.name || 'anonymous'}`"
        @input="emit('typing', $event)"
        @keyup.enter.exact="submit"
      />
      <input v-model.number="form.age" type="number" min="0" :max="MAX_AGE" />
      <textarea v-model.lazy="form.body" rows="3" />
      <input v-model="checked" type="checkbox" :true-value="'yes'" :false-value="'no'" />
      <select v-model="selected" :disabled="!canSelect">
        <option v-for="(label, value, index) in options" :key="value" :value="value">
          {{ index }}: {{ label }}
        </option>
      </select>
      <button type="submit" :disabled="pending" v-bind="buttonAttrs" @click.once="track">
        <slot name="submit" :pending="pending">Send</slot>
      </button>
    </form>

    <p v-if="status === 'loading'" v-show="visible">Loading&hellip;</p>
    <p v-else-if="status === 'error'" :class="$style.error" v-html="errorHtml" />
    <template v-else>
      <ul>
        <li
          v-for="(comment, index) in sortedComments"
          :key="comment.id"
          v-memo="[comment.id, comment.updatedAt]"
          :data-index="index"
          :style="{ '--depth': comment.depth, opacity: comment.hidden ? 0.5 : 1 }"
        >
          <template v-if="comment.author">{{ comment.author.name ?? 'anon' }}:</template>
          {{ comment.body }}
        </li>
      </ul>
      <p v-for="n in 3" :key="n">Page {{ n }}</p>
    </template>

    <component :is="currentView" v-bind="viewProps" @close="currentView = 'app-logo'" />

    <data-table :rows="comments" v-slot="{ row, remove }">
      <td>{{ row.id }}</td>
      <td><button @click.stop="remove(row)">x</button></td>
    </data-table>

    <base-layout>
      <template #header="{ title: headerTitle }">
        <h2>{{ headerTitle }}</h2>
      </template>
      <template #default>
        <app-logo size="small" />
      </template>
      <template v-slot:[dynamicSlot]="slotProps">
        <pre>{{ JSON.stringify(slotProps, null, 2) }}</pre>
      </template>
    </base-layout>

    <Teleport to="body" :disabled="!mounted">
      <Transition name="fade" mode="out-in" appear>
        <dialog v-if="dialogOpen" ref="dialogRef" open @close="dialogOpen = false">
          <TransitionGroup tag="ul" name="list">
            <li v-for="item in form.tags" :key="item">{{ item }}</li>
          </TransitionGroup>
        </dialog>
      </Transition>
    </Teleport>
  </main>
</template>

<script lang="ts">
import { Component, mixins } from 'nuxt-property-decorator'
import { Store } from 'vuex'
import { useStore } from 'vuex-simple'

import ActionBar from '~/components/ActionBar.vue'
import AppLogo from '~/components/AppLogo.vue'
import Comment from '~/components/Comment.vue'
import { RawCommentType } from '~/logic/comments/models'
import TypedStore from '~/logic/store'
import { StateType } from '~/logic/types'
import TypedStoreMixin from '~/mixins/typed-store'

// @vue/component
@Component({
  'components': {
    ActionBar,
    AppLogo,
    Comment,
  },
})
/**
 * Main page (or index page).
 * Mounted as `/` by default.
 */
export default class Index extends mixins(TypedStoreMixin) {
  /**
   * Fetches comments from external API from the server side.
   * This method should preload Vuex store.
   *
   * @see https://nuxtjs.org/api/pages-fetch
   * @param context - Nuxt `context` instance.
   * @param context.store - Current Vuex store.
   * @returns List of downloaded comments.
   */
  fetch({ store }: { store: Store<StateType> }): Promise<RawCommentType[]> {
    // Here we don't have a DI setup yet, so we use the explicit approach:
    const typedStore = useStore<TypedStore>(store)
    return typedStore.comments.fetchComments()
  }
}
</script>

<style lang="scss" module>
.main {
  max-width: 100%;
}

.container {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-evenly;
}
</style>

<script setup lang="ts">
import { ref, reactive, computed, watch, watchEffect, onMounted, onUnmounted, nextTick, type Ref } from 'vue'

interface CommentModel {
  id: number
  body: string
  depth: number
  hidden?: boolean
  updatedAt: Date
  author?: { name: string | null }
}

type Status = 'idle' | 'loading' | 'error' | 'ready'

const props = withDefaults(defineProps<{
  title?: string
  initial?: CommentModel[]
  pageSize?: number
}>(), {
  title: 'Comments',
  initial: () => [],
  pageSize: 20,
})

const emit = defineEmits<{
  (event: 'typing', payload: Event): void
  (event: 'submitted', comment: CommentModel): void
}>()

const checked = defineModel<'yes' | 'no'>('checked', { default: 'no' })
const selected = defineModel<string>({ required: false })

defineExpose({ reset })

const MAX_AGE = 120
const inputId = `name-${Math.random().toString(36).slice(2)}`
const comments = ref<CommentModel[]>([...props.initial])
const status = ref<Status>('idle')
const pending = ref(false)
const visible = ref(true)
const mounted = ref(false)
const dialogOpen = ref(false)
const isSticky = ref(false)
const currentView = ref('app-logo')
const dynamicSlot = ref('footer')
const attrName = ref('data-form')
const attrValue = ref('main')
const errorHtml = ref('<strong>Failed</strong> to load')
const dialogRef = ref<HTMLDialogElement | null>(null)
const total: Ref<number> = ref(1_000)
const form = reactive({ name: '', age: 0, body: '', tags: ['vue', 'ts'] as string[] })
const options: Record<string, string> = { a: 'Alpha', b: 'Beta' }
const viewProps = reactive<Record<string, unknown>>({ compact: true })
const buttonAttrs = { 'aria-label': 'Submit comment', tabindex: 0 }

const canSelect = computed(() => status.value !== 'loading' && Object.keys(options).length > 0)
const progress = computed<number>(() => Math.min(comments.value.length / total.value, 1))
const sortedComments = computed(() =>
  [...comments.value].sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime()),
)

watch(() => form.name, (name, previous) => {
  if (name !== previous) emit('typing', new Event('input'))
}, { immediate: false })

watch([status, pending], async ([nextStatus]) => {
  if (nextStatus === 'ready') await nextTick()
})

watchEffect((onCleanup) => {
  const timer = setTimeout(() => (isSticky.value = window.scrollY > 100), 200)
  onCleanup(() => clearTimeout(timer))
})

onMounted(async () => {
  mounted.value = true
  status.value = 'loading'
  try {
    const response = await fetch(`/api/comments?size=${props.pageSize}`)
    const payload = (await response.json()) as CommentModel[]
    comments.value = payload.map((item) => ({ ...item, updatedAt: new Date(item.updatedAt) }))
    status.value = 'ready'
  } catch (error) {
    console.error(error)
    status.value = 'error'
  }
})

onUnmounted(() => dialogRef.value?.close())

function reset(): void {
  Object.assign(form, { name: '', age: 0, body: '' })
}

function track() {
  console.info('clicked', structuredClone(form))
}

async function submit(): Promise<void> {
  pending.value = true
  const comment: CommentModel = {
    id: Date.now(),
    body: form.body,
    depth: 0,
    updatedAt: new Date(),
    author: { name: form.name || null },
  }
  comments.value.push(comment)
  emit('submitted', comment)
  pending.value = false
  reset()
}
</script>

<style lang="scss" scoped>
@use 'sass:math';

$duration: 0.3s;
$depth-step: 16px;

.fade-enter-active,
.fade-leave-active {
  transition: opacity $duration ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.list-move {
  transition: transform math.div($duration, 2);
}

form {
  :deep(.app-logo) {
    margin-inline: auto;
  }

  & > label {
    font-weight: 600;
  }
}

dialog {
  border-color: v-bind('form.name ? "teal" : "tomato"');
  padding-left: calc(var(--depth, 0) * #{$depth-step});
  --progress: v-bind(progress);
}
</style>
