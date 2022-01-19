<template>
  <div id="app">
    <div id="form">
      <SelectFromTable v-model="demand" @change="updateTable" v-on:demand="setDemandId" table_name="demand" v-bind:where_req="where_req" column="demand_id" />
      <SelectFromTable v-model="country" @change="updateTable" table_name="country_groups" v-bind:where_req="where_req"/>
      <SelectFromTable v-model="product" @change="updateTable" table_name="product_groups" v-bind:where_req="where_req"/>
      <br />
    </div>
    <div v-if="demand_id==''">Please select demand</div>
    <Chart v-if="chartReady >= 3 && demand_id != ''" :demand="demandSum" :production="productionSum" :budget="budgetSum" />
    <br />
    <Grid
      @change="updateDatabase" 
      v-if="demand_id!=''" 
      :gridRows="rows" 
      :columns="columns" />
  </div>
</template>

<script src="./App.js" />

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin: 60px 60px;
}
#form {
  display: flex;
}
</style>
