/* -*- c++ -*- */
/* 
 * Copyright 2024 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#pragma once

#include <testmodule/testblock.h>
#include <testmodule/testblock_block_ctrl.hpp>

namespace gr {
  namespace testmodule {

    class testblock_impl : public testblock
    {
     public:
      testblock_impl(::uhd::rfnoc::noc_block_base::sptr block_ref);
      ~testblock_impl();

      // Where all the action really happens

     private:
      ::uhd::rfnoc::testblock_block_ctrl::sptr d_testblock_ref;
    };

  } // namespace testmodule
} // namespace gr

