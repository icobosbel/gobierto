<template>
  <div class="gobierto-data-summary-queries">
    <div class="gobierto-data-summary-queries-panel pure-g">
      <div class="pure-u-1-2">
        <div class="gobierto-data-summary-queries-element">
          <h3
            class="gobierto-data-summary-queries-panel-title"
            @click="showYourQueries = !showYourQueries"
          >
            <i
              :class="showYourQueries ? '' : 'rotate-caret'"
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelYourQueries }} ({{ privateQueries.length }})
          </h3>
          <div
            v-for="(item, index) in privateQueries"
            v-show="showYourQueries"
            :key="index"
            class="gobierto-data-summary-queries-container"
            @mouseover="showCode(index)"
            @mouseleave="hideCode = true"
          >
            <span
              class="gobierto-data-summary-queries-container-name"
              @click="handleQueries(privateQueries[index].attributes.sql, item, false)"
            >
              {{ item.attributes.name }}
            </span>
            <div
              class="gobierto-data-summary-queries-container-icon"
            >
              <i
                class="fas fa-trash-alt icons-your-queries"
                style="color: var(--color-base);"
                @click="deleteQuery(item.id, index)"
              />
              <i
                v-if="item.attributes.privacy_status === 'closed'"
                style="color: #D0021B"
                class="fas fa-lock icons-your-queries"
              />
              <i
                v-else
                style="color: rgb(160, 197, 29)"
                class="fas fa-lock-open icons-your-queries"
              />
            </div>
          </div>
        </div>
        <div class="gobierto-data-summary-queries-element">
          <h3
            class="gobierto-data-summary-queries-panel-title"
            @click="showYourFavQueries = !showYourFavQueries"
          >
            <i
              :class="showYourFavQueries ? '' : 'rotate-caret'"
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelFavs }} ({{ numberFavQueries }})
          </h3>
        </div>
        <div class="gobierto-data-summary-queries-element">
          <h3
            class="gobierto-data-summary-queries-panel-title"
            @click="showYourTotalQueries = !showYourTotalQueries"
          >
            <i
              :class="showYourTotalQueries ? '' : 'rotate-caret'"
              class="fas fa-caret-down"
              style="color: var(--color-base);"
            />
            {{ labelAll }} ({{ publicQueries.length }})
          </h3>
          <div
            v-for="(item, index) in publicQueries"
            v-show="showYourTotalQueries"
            :key="index"
            class="gobierto-data-summary-queries-container"
            @mouseover="showCodePublic(index)"
            @mouseleave="hideCode = true"
            @click="handleQueries(publicQueries[index].attributes.sql, item)"
          >
            <span class="gobierto-data-summary-queries-container-name"> {{ item.attributes.name }}</span>
          </div>
        </div>
      </div>
      <div class="pure-u-1-2 border-color-queries">
        <p class="gobierto-data-summary-queries-sql-code">
          <span v-if="!hideCode"> {{ sqlCode }}</span>
        </p>
      </div>
    </div>
  </div>
</template>
<script>
import axios from 'axios';
import { getToken, getUserId } from './../../../lib/helpers';
import { baseUrl } from "./../../../lib/commons.js"
export default {
  name: "Queries",
  props: {
    privateQueries: {
      type: Array,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      labelQueries: '',
      labelYourQueries: '',
      labelFavs: '',
      labelAll: '',
      hideCode: true,
      sqlCode: '',
      numberQueries: 0,
      numberFavQueries: 0,
      totalQueries: 0,
      showSection: true,
      showYourQueries: true,
      showYourFavQueries: true,
      showYourTotalQueries: true,
      token: '',
      endPoint: '',
      filterId: '',
      url: '',
      endPointDelete: '',
      numberId: ''
    }
  },
  created() {
    this.numberId = this.$route.params.numberId
    this.numberQueries = this.privateQueries.length
    this.totalQueries = this.privateQueries.length + this.numberFavQueries

    this.labelYourQueries = I18n.t("gobierto_data.projects.yourQueries")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelFavs = I18n.t("gobierto_data.projects.favs")
    this.labelAll = I18n.t("gobierto_data.projects.all")
    this.token = getToken()
    this.userId = getUserId()

  },
  methods: {
    handleQueries(sql, item, anonymusQuery) {
      this.runYourQuery(sql)
      this.sendQuery(item)
      this.closeModal()
      this.changeTab()
      if (anonymusQuery === true) {
        this.$root.$emit('disableEdit')
      }
    },
    closeModal() {
      this.$root.$emit('closeQueriesModal');
    },
    showCode(index) {
      this.hideCode = false
      this.sqlCode = this.privateQueries[index].attributes.sql
    },
    showCodePublic(index) {
      this.hideCode = false
      this.sqlCode = this.publicQueries[index].attributes.sql
    },
    sendQuery(item) {
      this.queryParams = [item.attributes.name, item.attributes.privacy_status, item.attributes.sql, item.id, item.attributes.user_id ]
      this.queryCode = item.attributes.sql
      this.$root.$emit('sendQueryParams', this.queryParams)
      this.$root.$emit('sendQueryCode', this.queryCode)
    },
    toggle() {
      this.showSection = !this.showSection
    },
    changeTab() {
      this.$root.$emit('changeNavTab')
    },
    deleteQuery(id, index) {
      this.$delete(this.privateQueries, index)
      this.deleteQueryApi(id)
    },
    deleteQueryApi(id) {
      const endPointDelete = `${baseUrl}/queries/${id}`
      axios.delete(endPointDelete, {
        headers: {
          'Content-type': 'application/json',
          'Authorization': `${this.token}`
        }
      })

      this.endPoint = `${baseUrl}/queries?filter[dataset_id]=`
      this.filterId = `&filter[user_id]=${this.userId}`
      this.url = `${this.endPoint}${this.numberId}${this.filterId}`
      axios
        .get(this.url)
        .then(response => {
          const rawData = response.data
          const items = rawData.data
          this.privateQueries = items
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
    runYourQuery(code) {
      this.queryEditor = encodeURI(code)
      this.$root.$emit('postRecentQuery', code)
      this.$root.$emit('showMessages', false, true)
      this.$root.$emit('updateCode', code)
      const queryEditorLowerCase = this.queryEditor.toLowerCase()

      if (queryEditorLowerCase.includes('limit')) {
        this.queryEditor = this.queryEditor
        this.$root.$emit('hiddeShowButtonColumns')
      } else {
        this.$root.$emit('ShowButtonColumns')
        this.$root.$emit('sendCompleteQuery', this.queryEditor)
        this.code = `SELECT%20*%20FROM%20(${this.queryEditor})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`
        this.queryEditor = this.code
      }
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/data';
      this.url = `${this.urlPath}${this.endPoint}?sql=${this.queryEditor}`

      axios
        .get(this.url)
        .then(response => {
          let data = []
          let keysData = []
          const rawData = response.data
          const meta = rawData.meta
          data = rawData.data

          const queryDurationRecords = [ meta.rows, meta.duration ]

          keysData = Object.keys(data[0])

          this.$root.$emit('recordsDuration', queryDurationRecords)
          this.$root.$emit('sendData', keysData, data)
          this.$root.$emit('sendDataViz', data)
          this.$root.$emit('showMessages', true, false)
          this.$root.$emit('sendQueryCode', this.queryCode)
          this.$root.$emit('activateModalRecent')
          this.$root.$emit('runSpinner')

        })
        .catch(error => {
          const messageError = error.response.data.errors[0].sql
          this.$root.$emit('apiError', messageError)

          const data = []
          const keysData = []
          this.$root.$emit('sendData', keysData, data)
        })
    }
  }
}
</script>
